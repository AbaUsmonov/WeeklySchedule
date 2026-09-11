//
//  Lesson.swift
//  WeeklySchedule
//

import Foundation

struct Lesson: Identifiable, Hashable {
    let id = UUID()
    let weekday: Weekday
    let order: Int              // 1...4, displayed as roman numeral I-IV
    let startTime: String       // "08:00"
    let endTime: String         // "09:20"
    let subject: String
    let teacher: String?
    let room: String?
    let parity: LessonParity
    let isJoint: Bool           // "поточная" — shared lecture with parallel groups

    var isVacant: Bool { teacher == "ВАКАНТ" }

    var romanOrder: String {
        ["I", "II", "III", "IV"][max(0, min(order - 1, 3))]
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        return formatter
    }()

    /// Resolves this lesson's start time onto the given calendar day.
    func startDate(on day: Date, calendar: Calendar = .current) -> Date? {
        Self.combine(time: startTime, withDay: day, calendar: calendar)
    }

    /// Resolves this lesson's end time onto the given calendar day.
    func endDate(on day: Date, calendar: Calendar = .current) -> Date? {
        Self.combine(time: endTime, withDay: day, calendar: calendar)
    }

    private static func combine(time: String, withDay day: Date, calendar: Calendar) -> Date? {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return calendar.date(bySettingHour: parts[0], minute: parts[1], second: 0, of: day)
    }
}
