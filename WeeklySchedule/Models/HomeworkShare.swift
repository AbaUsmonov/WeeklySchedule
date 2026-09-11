//
//  HomeworkShare.swift
//  WeeklySchedule
//
//  A self-contained, AirDrop-able snapshot of a single homework note — the task
//  text/subject/due date plus the raw photo bytes, so the receiving device
//  doesn't need any shared backend to reconstruct it.
//

import Foundation

struct HomeworkShare: Codable {
    let subject: String
    let text: String
    let dueDate: Date?
    let photoData: Data?

    static let fileExtension = "weeklyhw"

    /// Writes this payload to a temporary file suitable for `ShareLink`/AirDrop.
    func writeToTemporaryFile() -> URL? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }

        let safeSubject = subject
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "_")
        let baseName = safeSubject.isEmpty ? "Задание" : safeSubject
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(baseName)-\(UUID().uuidString.prefix(6))")
            .appendingPathExtension(Self.fileExtension)

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    static func load(from url: URL) -> HomeworkShare? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(HomeworkShare.self, from: data)
    }
}
