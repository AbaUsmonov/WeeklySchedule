//
//  Weekday.swift
//  WeeklySchedule
//

import Foundation

enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    /// Maps to `Calendar` weekday component (1 = Sunday ... 7 = Saturday).
    var calendarComponent: Int { rawValue }

    var fullName: String {
        switch self {
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        }
    }

    var shortName: String {
        switch self {
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        }
    }

    init?(date: Date, calendar: Calendar = .current) {
        self.init(rawValue: calendar.component(.weekday, from: date))
    }
}
