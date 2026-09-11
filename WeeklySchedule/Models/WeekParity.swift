//
//  WeekParity.swift
//  WeeklySchedule
//

import Foundation

enum WeekParity: String, Codable, CaseIterable, Identifiable {
    case odd
    case even

    var id: String { rawValue }

    var title: String {
        switch self {
        case .odd: "Нечётная"
        case .even: "Чётная"
        }
    }

    var shortTitle: String {
        switch self {
        case .odd: "Нечёт"
        case .even: "Чёт"
        }
    }

    var opposite: WeekParity { self == .odd ? .even : .odd }
}

/// A lesson can happen only on odd weeks, only on even weeks, or every week.
enum LessonParity: String, Codable {
    case odd
    case even
    case both

    func matches(_ current: WeekParity) -> Bool {
        switch self {
        case .both: true
        case .odd: current == .odd
        case .even: current == .even
        }
    }
}
