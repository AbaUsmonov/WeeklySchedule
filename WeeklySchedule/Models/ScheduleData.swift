//
//  ScheduleData.swift
//  WeeklySchedule
//
//  Mock data: Группа 1 ПИВ, Естественнонаучный факультет,
//  Осенний семестр 2026/2027, 1-я смена.
//

import Foundation

enum ScheduleData {

    private static let times: [Int: (start: String, end: String)] = [
        1: ("08:00", "09:20"),
        2: ("09:30", "10:50"),
        3: ("11:00", "12:20"),
        4: ("12:40", "14:00"),
    ]

    private static func lesson(
        _ day: Weekday,
        _ order: Int,
        subject: String,
        teacher: String? = nil,
        room: String? = nil,
        parity: LessonParity = .both,
        isJoint: Bool = false
    ) -> Lesson {
        let time = times[order]!
        return Lesson(
            weekday: day,
            order: order,
            startTime: time.start,
            endTime: time.end,
            subject: subject,
            teacher: teacher,
            room: room,
            parity: parity,
            isJoint: isJoint
        )
    }

    static let all: [Lesson] = [
        // MARK: Понедельник
        lesson(.monday, 1, subject: "История России", teacher: "Абдубасиров А.А.", room: "213"),
        lesson(.monday, 2, subject: "Практический курс русского языка", teacher: "ВАКАНТ", room: "228"),
        lesson(.monday, 3, subject: "Физическое воспитание", teacher: "Вольфович П.С."),
        lesson(.monday, 4, subject: "ТОСИО", teacher: "Абдулхаева Ш.Р.", room: "214", parity: .even),

        // MARK: Вторник
        lesson(.tuesday, 1, subject: "Физическое воспитание", teacher: "Вольфович П.С."),
        lesson(.tuesday, 2, subject: "Информатика", teacher: "Махкамов Ф.М., Одинаева М.А.", room: "218/223"),
        lesson(.tuesday, 3, subject: "Основы российской государственности", teacher: "Умедов К.М.", room: "226"),
        lesson(.tuesday, 4, subject: "Дискретная математика", teacher: "Исроилов И.", room: "207", parity: .even),

        // MARK: Среда
        lesson(.wednesday, 1, subject: "Мировая литература", teacher: "Кудратова С.", room: "230", parity: .odd),
        lesson(.wednesday, 1, subject: "Практический курс русского языка", teacher: "ВАКАНТ", room: "230", parity: .even),
        lesson(.wednesday, 2, subject: "Математика", teacher: "ВАКАНТ", room: "214"),
        lesson(.wednesday, 3, subject: "ТОСИО", teacher: "Абдулхаева Ш.Р.", parity: .odd),

        // MARK: Четверг
        lesson(.thursday, 1, subject: "Экономическая теория", teacher: "Шамсуддинов А.Х.", room: "214"),
        lesson(.thursday, 2, subject: "Основы российской государственности", teacher: "Умедов К.М.", room: "213", parity: .odd),
        lesson(.thursday, 2, subject: "Экономическая теория", teacher: "Рахматзода Х.Б.", room: "213", parity: .even),
        lesson(.thursday, 3, subject: "Таджикский язык в ПД", teacher: "Зулфониён Р.Р.", room: "226"),

        // MARK: Пятница
        lesson(.friday, 1, subject: "История России", teacher: "Каххаров Т.И.", room: "226"),
        lesson(.friday, 2, subject: "Иностранный язык", teacher: "Атаджанова П.Н.", room: "228"),
        lesson(.friday, 3, subject: "Дискретная математика", teacher: "Исроилов И.", room: "214", parity: .odd),
        lesson(.friday, 3, subject: "Математика", teacher: "ВАКАНТ", room: "214", parity: .even),

        // MARK: Суббота
        lesson(.saturday, 1, subject: "История России", teacher: "Каххаров Т.И.", room: "410", isJoint: true),
        lesson(.saturday, 2, subject: "История России", teacher: "Каххаров Т.И.", room: "410", isJoint: true),
    ]

    /// All lessons for a given weekday, filtered by week parity, sorted by order.
    static func lessons(for day: Weekday, parity: WeekParity) -> [Lesson] {
        all
            .filter { $0.weekday == day && $0.parity.matches(parity) }
            .sorted { $0.order < $1.order }
    }

    /// Distinct subject names across the whole schedule, sorted alphabetically.
    static var allSubjects: [String] {
        Array(Set(all.map(\.subject))).sorted { $0.localizedCompare($1) == .orderedAscending }
    }
}
