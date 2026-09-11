//
//  HomeworkTask.swift
//  WeeklySchedule
//

import Foundation

struct HomeworkTask: Identifiable, Codable, Equatable {
    let id: UUID
    var subject: String
    var text: String
    var isDone: Bool
    var createdAt: Date
    var photoFileName: String?
    var dueDate: Date?

    init(
        id: UUID = UUID(),
        subject: String,
        text: String,
        isDone: Bool = false,
        createdAt: Date = Date(),
        photoFileName: String? = nil,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.subject = subject
        self.text = text
        self.isDone = isDone
        self.createdAt = createdAt
        self.photoFileName = photoFileName
        self.dueDate = dueDate
    }

    var isOverdue: Bool {
        guard !isDone, let dueDate else { return false }
        return dueDate < Calendar.current.startOfDay(for: Date())
    }

    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
}
