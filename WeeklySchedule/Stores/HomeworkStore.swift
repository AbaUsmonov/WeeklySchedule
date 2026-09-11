//
//  HomeworkStore.swift
//  WeeklySchedule
//

import Foundation
import Combine
#if os(iOS) || os(visionOS)
import UIKit
#else
import AppKit
#endif

@MainActor
final class HomeworkStore: ObservableObject {

    @Published private(set) var tasks: [HomeworkTask] = [] {
        didSet { persist() }
    }

    private let defaults = UserDefaults.standard
    private let storageKey = "homework.tasks.v1"

    init() {
        load()
    }

    func tasks(for subject: String) -> [HomeworkTask] {
        tasks
            .filter { $0.subject == subject }
            .sorted(by: Self.taskOrdering)
    }

    func pendingCount(for subject: String) -> Int {
        tasks.filter { $0.subject == subject && !$0.isDone }.count
    }

    func pendingTasks(forSubjects subjects: [String]) -> [HomeworkTask] {
        tasks
            .filter { subjects.contains($0.subject) && !$0.isDone }
            .sorted(by: Self.taskOrdering)
    }

    /// Incomplete tasks first (soonest due date first, undated ones last), then completed tasks.
    private static func taskOrdering(_ lhs: HomeworkTask, _ rhs: HomeworkTask) -> Bool {
        if lhs.isDone != rhs.isDone { return !lhs.isDone && rhs.isDone }
        switch (lhs.dueDate, rhs.dueDate) {
        case let (l?, r?): return l == r ? lhs.createdAt < rhs.createdAt : l < r
        case (.some, nil): return true
        case (nil, .some): return false
        case (nil, nil): return lhs.createdAt < rhs.createdAt
        }
    }

    func add(subject: String, text: String, photoFileName: String? = nil, dueDate: Date? = nil) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || photoFileName != nil else { return }
        tasks.append(HomeworkTask(subject: subject, text: trimmed, photoFileName: photoFileName, dueDate: dueDate))
    }

    func toggle(_ task: HomeworkTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
    }

    func delete(_ task: HomeworkTask) {
        deleteImageFile(task.photoFileName)
        tasks.removeAll { $0.id == task.id }
    }

    func delete(at offsets: IndexSet, in subjectTasks: [HomeworkTask]) {
        let toDelete = offsets.map { subjectTasks[$0] }
        toDelete.forEach { deleteImageFile($0.photoFileName) }
        let idsToDelete = Set(toDelete.map(\.id))
        tasks.removeAll { idsToDelete.contains($0.id) }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([HomeworkTask].self, from: data)
        else { return }
        tasks = decoded
    }

    // MARK: - Photos

    private var imagesDirectory: URL {
        let dir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("HomeworkPhotos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    /// Compresses and writes the image to disk, returning the stored file name (or nil on failure).
    func saveImage(_ image: PlatformImage) -> String? {
        guard let data = image.jpegDataCompatible(quality: 0.7) else { return nil }
        let fileName = "\(UUID().uuidString).jpg"
        do {
            try data.write(to: imagesDirectory.appendingPathComponent(fileName))
            return fileName
        } catch {
            return nil
        }
    }

    func loadImage(fileName: String) -> PlatformImage? {
        PlatformImage(contentsOfFile: imagesDirectory.appendingPathComponent(fileName).path)
    }

    private func deleteImageFile(_ fileName: String?) {
        guard let fileName else { return }
        try? FileManager.default.removeItem(at: imagesDirectory.appendingPathComponent(fileName))
    }

    // MARK: - Sharing

    /// Bundles a task (and its photo, if any) into a standalone file for AirDrop/share sheet.
    func makeShareFile(for task: HomeworkTask) -> URL? {
        let photoData = task.photoFileName.flatMap { fileName in
            try? Data(contentsOf: imagesDirectory.appendingPathComponent(fileName))
        }
        let share = HomeworkShare(subject: task.subject, text: task.text, dueDate: task.dueDate, photoData: photoData)
        return share.writeToTemporaryFile()
    }

    /// Imports a task received via AirDrop/Open-In. The photo (if any) is saved into the
    /// app's own storage so it shows in the task card, and separately handed back to the
    /// caller so it can also be dropped into the system Photos library.
    @discardableResult
    func importShare(_ share: HomeworkShare) -> PlatformImage? {
        var photoFileName: String?
        var image: PlatformImage?
        if let photoData = share.photoData, let decoded = PlatformImage(data: photoData) {
            image = decoded
            photoFileName = saveImage(decoded)
        }
        add(subject: share.subject, text: share.text, photoFileName: photoFileName, dueDate: share.dueDate)
        return image
    }
}
