//
//  DayStatus.swift
//  WeeklySchedule
//

import Foundation

/// Describes what's happening *right now* relative to a day's lessons.
enum DayStatus {
    case noClasses
    case beforeFirst(first: Lesson, minutesLeft: Int)
    case inLesson(Lesson, minutesLeft: Int)
    case onBreak(next: Lesson, minutesLeft: Int)
    case finished(last: Lesson)
}

enum DayStatusCalculator {
    static func status(for lessons: [Lesson], now: Date, calendar: Calendar = .current) -> DayStatus {
        let sorted = lessons.sorted { $0.order < $1.order }
        guard !sorted.isEmpty else { return .noClasses }

        for (index, lesson) in sorted.enumerated() {
            guard let start = lesson.startDate(on: now, calendar: calendar),
                  let end = lesson.endDate(on: now, calendar: calendar)
            else { continue }

            if now >= start && now <= end {
                let minutesLeft = max(0, Int(end.timeIntervalSince(now) / 60))
                return .inLesson(lesson, minutesLeft: minutesLeft)
            }

            if now < start {
                let minutesLeft = max(0, Int(start.timeIntervalSince(now) / 60))
                if index == 0 {
                    return .beforeFirst(first: lesson, minutesLeft: minutesLeft)
                } else {
                    return .onBreak(next: lesson, minutesLeft: minutesLeft)
                }
            }
        }

        return .finished(last: sorted[sorted.count - 1])
    }
}
