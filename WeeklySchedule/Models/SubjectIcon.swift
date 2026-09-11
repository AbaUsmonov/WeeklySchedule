//
//  SubjectIcon.swift
//  WeeklySchedule
//

import Foundation

enum SubjectIcon {

    private static let symbols: [String: String] = [
        "История России": "building.columns.fill",
        "Практический курс русского языка": "textformat.abc",
        "Физическое воспитание": "figure.run",
        "ТОСИО": "person.3.fill",
        "Информатика": "laptopcomputer",
        "Основы российской государственности": "flag.fill",
        "Дискретная математика": "function",
        "Мировая литература": "book.fill",
        "Математика": "x.squareroot",
        "Экономическая теория": "chart.line.uptrend.xyaxis",
        "Таджикский язык в ПД": "quote.bubble.fill",
        "Иностранный язык": "globe",
    ]

    static func symbolName(for subject: String) -> String {
        symbols[subject] ?? "book.closed.fill"
    }
}
