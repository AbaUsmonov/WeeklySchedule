//
//  ScheduleStore.swift
//  WeeklySchedule
//

import Foundation
import Combine

/// Publishes the current week parity (odd/even) and lets the user override
/// the automatic calendar-based guess if it doesn't match the dean's office variant.
@MainActor
final class ScheduleStore: ObservableObject {

    @Published var manualParity: WeekParity? {
        didSet { persistManualParity() }
    }

    private let defaults = UserDefaults.standard
    private let manualParityKey = "schedule.manualParity"

    init() {
        if let raw = defaults.string(forKey: manualParityKey) {
            manualParity = WeekParity(rawValue: raw)
        } else {
            manualParity = nil
        }
    }

    var isAutomatic: Bool { manualParity == nil }

    /// The parity actually used throughout the app right now.
    func currentParity(on date: Date = Date()) -> WeekParity {
        manualParity ?? automaticParity(on: date)
    }

    /// Exact per-week parity for the Осенний семестр 2026/2027, taken straight from the
    /// dean's office schedule (each entry is the Monday of a study week). There's a real
    /// gap between 23.11 and 07.12 (no listed week for 30.11) — a non-teaching break week —
    /// so this is a lookup, not a clean formula: any date is resolved to the last anchor at
    /// or before its own week's Monday, which naturally extends 23.11's parity through that
    /// break, exactly like the paper schedule implies.
    private static let semesterWeekAnchors: [(monday: Date, parity: WeekParity)] = {
        let calendar = Calendar(identifier: .gregorian)
        func day(_ month: Int, _ day: Int) -> Date {
            calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
        }
        return [
            (day(8, 31), .odd),   // week 1  · 02.09
            (day(9, 7), .even),   // week 2  · 09.09
            (day(9, 14), .odd),   // week 3  · 16.09
            (day(9, 21), .even),  // week 4  · 23.09
            (day(9, 28), .odd),   // week 5  · 30.09
            (day(10, 5), .even),  // week 6  · 07.10
            (day(10, 12), .odd),  // week 7  · 14.10
            (day(10, 19), .even), // week 8  · 21.10
            (day(10, 26), .odd),  // week 9  · 28.10
            (day(11, 2), .even),  // week 10 · 04.11
            (day(11, 9), .odd),   // week 11 · 11.11
            (day(11, 16), .even), // week 12 · 18.11
            (day(11, 23), .odd),  // week 13 · 25.11
            (day(12, 7), .even),  // week 14 · 09.12 (break week 30.11–05.12 has no lessons)
            (day(12, 14), .odd),  // week 15 · 16.12
            (day(12, 21), .even), // week 16 · 23.12
            (day(12, 28), .odd),  // week 17 · 30.12
        ]
    }()

    /// The Monday (00:00) of the ISO calendar week containing `date`.
    private func mondayOfWeek(containing date: Date) -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }

    /// Exact parity from the dean's office anchor table, extrapolated by simple weekly
    /// alternation before the first anchor or after the last one.
    func automaticParity(on date: Date) -> WeekParity {
        let weekMonday = mondayOfWeek(containing: date)
        let gregorian = Calendar(identifier: .gregorian)
        let anchors = Self.semesterWeekAnchors

        if let last = anchors.last(where: { $0.monday <= weekMonday }) {
            let days = gregorian.dateComponents([.day], from: last.monday, to: weekMonday).day ?? 0
            let weeksAway = days / 7
            return weeksAway.isMultiple(of: 2) ? last.parity : last.parity.opposite
        } else if let first = anchors.first {
            let days = gregorian.dateComponents([.day], from: weekMonday, to: first.monday).day ?? 0
            let weeksAway = days / 7
            return weeksAway.isMultiple(of: 2) ? first.parity : first.parity.opposite
        }

        var isoCalendar = Calendar(identifier: .iso8601)
        isoCalendar.timeZone = .current
        let week = isoCalendar.component(.weekOfYear, from: date)
        return week % 2 == 0 ? .even : .odd
    }

    func setManual(_ parity: WeekParity) {
        manualParity = parity
    }

    func resetToAutomatic() {
        manualParity = nil
    }

    /// Parity for an arbitrary (possibly future) date. Unlike `currentParity(on:)`, a manual
    /// override here is treated as a constant weekly-alternation correction rather than a
    /// blanket answer, so dates in other weeks still alternate correctly around it.
    func parity(on date: Date) -> WeekParity {
        let auto = automaticParity(on: date)
        guard let manualParity else { return auto }
        let autoToday = automaticParity(on: Date())
        return manualParity == autoToday ? auto : auto.opposite
    }

    /// The next calendar date (strictly after `referenceDate`) on which this subject has a lesson,
    /// accounting for weekday and odd/even-week variants. Returns nil if the subject never occurs
    /// or no match is found within a two-month lookahead.
    func nextLessonDate(forSubject subject: String, after referenceDate: Date = Date()) -> Date? {
        let calendar = Calendar.current
        let subjectLessons = ScheduleData.all.filter { $0.subject == subject }
        guard !subjectLessons.isEmpty else { return nil }

        var candidate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: referenceDate))!
        for _ in 0..<60 {
            if let weekday = Weekday(date: candidate, calendar: calendar) {
                let candidateParity = parity(on: candidate)
                if subjectLessons.contains(where: { $0.weekday == weekday && $0.parity.matches(candidateParity) }) {
                    return candidate
                }
            }
            candidate = calendar.date(byAdding: .day, value: 1, to: candidate)!
        }
        return nil
    }

    private func persistManualParity() {
        if let manualParity {
            defaults.set(manualParity.rawValue, forKey: manualParityKey)
        } else {
            defaults.removeObject(forKey: manualParityKey)
        }
    }
}
