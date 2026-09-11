//
//  SubjectHomeworkView.swift
//  WeeklySchedule
//

import SwiftUI
import PhotosUI

struct SubjectHomeworkView: View {
    let subject: String

    @EnvironmentObject private var homeworkStore: HomeworkStore
    @EnvironmentObject private var scheduleStore: ScheduleStore
    @EnvironmentObject private var appearanceStore: AppearanceStore
    @State private var newTaskText = ""
    @State private var pendingImage: PlatformImage?
    @State private var pendingDueDate: Date?
    @State private var draftDueDate = Date()
    @State private var pickerItem: PhotosPickerItem?
    @State private var showPhotosPicker = false
    @State private var showAttachOptions = false
    @State private var showDueDatePicker = false
    @State private var viewingImage: PlatformImage?
    #if os(iOS)
    @State private var showCamera = false
    #endif
    @FocusState private var fieldFocused: Bool

    private var accent: Color { AppTheme.subjectAccent(for: subject) }
    private var tasks: [HomeworkTask] { homeworkStore.tasks(for: subject) }
    private var doneCount: Int { tasks.count(where: \.isDone) }
    private var nextLessonDate: Date? { scheduleStore.nextLessonDate(forSubject: subject) }

    private var cameraAvailable: Bool {
        #if os(iOS)
        UIImagePickerController.isSourceTypeAvailable(.camera)
        #else
        false
        #endif
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if tasks.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(tasks) { task in
                        TaskNoteCard(task: task, accent: accent, onToggle: {
                            withAnimation(.snappy) { homeworkStore.toggle(task) }
                        }, onTapPhoto: { image in
                            viewingImage = image
                        })
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { offsets in
                        withAnimation(.snappy) { homeworkStore.delete(at: offsets, in: tasks) }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 0)
            }

            addBar
        }
        .background(AppTheme.pageBackground)
        .navigationBarTitleDisplayModeIfAvailable()
        .tabBarHiddenIfAvailable()
        .confirmationDialog("Добавить фото", isPresented: $showAttachOptions, titleVisibility: .visible) {
            #if os(iOS)
            if cameraAvailable {
                Button("Сделать фото") { showCamera = true }
            }
            #endif
            Button("Выбрать из галереи") { showPhotosPicker = true }
            Button("Отмена", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = PlatformImage(data: data) {
                    pendingImage = image
                }
                pickerItem = nil
            }
        }
        #if os(iOS)
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                pendingImage = image
            }
            .ignoresSafeArea()
            .preferredColorScheme(appearanceStore.appearance.colorScheme)
        }
        #endif
        .sheet(isPresented: $showDueDatePicker) {
            DueDatePickerSheet(
                date: $draftDueDate,
                accent: accent,
                nextLessonDate: nextLessonDate,
                onSelect: { chosen in
                    pendingDueDate = chosen
                    showDueDatePicker = false
                },
                onClear: {
                    pendingDueDate = nil
                    showDueDatePicker = false
                }
            )
            .preferredColorScheme(appearanceStore.appearance.colorScheme)
        }
        .fullScreenCoverCompat(isPresented: Binding(
            get: { viewingImage != nil },
            set: { if !$0 { viewingImage = nil } }
        )) {
            if let viewingImage {
                PhotoViewerView(image: viewingImage) { self.viewingImage = nil }
                    .preferredColorScheme(appearanceStore.appearance.colorScheme)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(accent.opacity(0.18))
                Image(systemName: SubjectIcon.symbolName(for: subject))
                    .foregroundStyle(accent)
                    .font(.title3)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(subject)
                    .font(.title3.weight(.bold))
                    .lineLimit(2)

                Text(tasks.isEmpty ? "Заданий пока нет" : "\(doneCount) из \(tasks.count) выполнено")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppTheme.pageBackground)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "note.text")
                .font(.system(size: 36))
                .foregroundStyle(accent.opacity(0.6))
            Text("Пока пусто")
                .font(.headline)
            Text("Добавь первую заметку ниже — можно с фото и сроком сдачи.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var addBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            if pendingImage != nil || pendingDueDate != nil {
                HStack(spacing: 8) {
                    if let pendingImage {
                        ZStack(alignment: .topTrailing) {
                            Image(platformImage: pendingImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                            Button {
                                self.pendingImage = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .black.opacity(0.55))
                                    .font(.system(size: 16))
                            }
                            .offset(x: 5, y: -5)
                        }
                    }

                    if let pendingDueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(pendingDueDate.formatted(.dateTime.day().month(.abbreviated).locale(Locale(identifier: "ru_RU"))))
                            Button {
                                self.pendingDueDate = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(accent.opacity(0.14), in: Capsule())
                    }

                    Spacer()
                }
                .padding(.leading, 2)
            }

            HStack(spacing: 10) {
                Button {
                    if cameraAvailable {
                        showAttachOptions = true
                    } else {
                        showPhotosPicker = true
                    }
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(pendingImage == nil ? accent : AppTheme.successColor)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.cardBackground, in: Circle())
                }

                Button {
                    draftDueDate = pendingDueDate ?? Date()
                    showDueDatePicker = true
                } label: {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 17))
                        .foregroundStyle(pendingDueDate == nil ? accent : AppTheme.successColor)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.cardBackground, in: Circle())
                }

                TextField("Новая заметка…", text: $newTaskText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused($fieldFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.smallCornerRadius, style: .continuous))
                    .onSubmit(addTask)

                Button(action: addTask) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(canSend ? accent : Color.secondary.opacity(0.4))
                }
                .disabled(!canSend)
            }
        }
        .padding(12)
        .background(.bar)
    }

    private var canSend: Bool {
        !newTaskText.trimmingCharacters(in: .whitespaces).isEmpty || pendingImage != nil
    }

    private func addTask() {
        guard canSend else { return }
        let photoFileName = pendingImage.flatMap { homeworkStore.saveImage($0) }
        homeworkStore.add(subject: subject, text: newTaskText, photoFileName: photoFileName, dueDate: pendingDueDate)
        newTaskText = ""
        pendingImage = nil
        pendingDueDate = nil
        fieldFocused = true
    }
}

private struct TaskNoteCard: View {
    let task: HomeworkTask
    let accent: Color
    let onToggle: () -> Void
    let onTapPhoto: (PlatformImage) -> Void

    @EnvironmentObject private var homeworkStore: HomeworkStore
    @State private var shareURL: URL?

    private var thumbnail: PlatformImage? {
        guard let fileName = task.photoFileName else { return nil }
        return homeworkStore.loadImage(fileName: fileName)
    }

    private var stripeColor: Color {
        if task.isDone { return AppTheme.successColor }
        if task.isOverdue { return .red }
        if task.isDueToday { return AppTheme.warningColor }
        return accent
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(stripeColor)
                .frame(width: 4)
                .padding(.vertical, 4)

            HStack(alignment: .top, spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(task.isDone ? AppTheme.successColor : accent)
                }
                .buttonStyle(.plain)
                .padding(.top, 1)

                VStack(alignment: .leading, spacing: 10) {
                    if !task.text.isEmpty {
                        Text(task.text)
                            .font(.body)
                            .strikethrough(task.isDone, color: .secondary)
                            .foregroundStyle(task.isDone ? .secondary : .primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let thumbnail {
                        Button {
                            onTapPhoto(thumbnail)
                        } label: {
                            Image(platformImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .opacity(task.isDone ? 0.6 : 1)
                        }
                        .buttonStyle(.plain)
                    }

                    if let dueDate = task.dueDate {
                        DueDateBadge(date: dueDate, isDone: task.isDone, isOverdue: task.isOverdue, isDueToday: task.isDueToday)
                    }
                }

                Spacer(minLength: 0)

                Button {
                    shareURL = homeworkStore.makeShareFile(for: task)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
        }
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.smallCornerRadius, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.smallCornerRadius, style: .continuous))
        .opacity(task.isDone ? 0.6 : 1)
        #if os(iOS)
        .sheet(isPresented: Binding(
            get: { shareURL != nil },
            set: { if !$0 { shareURL = nil } }
        )) {
            if let shareURL {
                ActivityShareSheet(items: [shareURL])
            }
        }
        #endif
    }
}

private struct DueDateBadge: View {
    let date: Date
    let isDone: Bool
    let isOverdue: Bool
    let isDueToday: Bool

    private var color: Color {
        if isDone { return .secondary }
        if isOverdue { return .red }
        if isDueToday { return AppTheme.warningColor }
        return .secondary
    }

    private var label: String {
        if isOverdue { return "Просрочено · \(formatted)" }
        if isDueToday { return "Сегодня" }
        return "До \(formatted)"
    }

    private var formatted: String {
        date.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "ru_RU")))
    }

    var body: some View {
        Label(label, systemImage: isOverdue ? "exclamationmark.circle.fill" : "calendar")
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.14), in: Capsule())
    }
}

private struct DueDatePickerSheet: View {
    @Binding var date: Date
    let accent: Color
    let nextLessonDate: Date?
    let onSelect: (Date) -> Void
    let onClear: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showManualPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    if let nextLessonDate {
                        Button {
                            onSelect(nextLessonDate)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle().fill(accent.opacity(0.18))
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundStyle(accent)
                                }
                                .frame(width: 40, height: 40)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("К следующему уроку")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text(nextLessonDate.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "ru_RU"))))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(12)
                            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.smallCornerRadius, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        withAnimation(.snappy) { showManualPicker.toggle() }
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(accent.opacity(0.18))
                                Image(systemName: "calendar")
                                    .foregroundStyle(accent)
                            }
                            .frame(width: 40, height: 40)

                            Text("Выбрать дату самому")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)

                            Spacer()
                            Image(systemName: showManualPicker ? "chevron.up" : "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(12)
                        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.smallCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    if showManualPicker {
                        VStack(spacing: 12) {
                            DatePicker("Дата", selection: $date, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(accent)

                            Button {
                                onSelect(date)
                            } label: {
                                Text("Готово")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(accent)
                        }
                        .padding(12)
                        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.smallCornerRadius, style: .continuous))
                    }

                    Button("Без срока", role: .destructive, action: onClear)
                        .padding(.top, 4)
                }
                .padding(16)
            }
            .background(AppTheme.pageBackground)
            .navigationTitle("Срок выполнения")
            .navigationBarTitleDisplayModeIfAvailable()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
        .environment(\.locale, Locale(identifier: "ru_RU"))
        .presentationDetents([.medium, .large])
    }
}

private struct PhotoViewerView: View {
    let image: PlatformImage
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            Image(platformImage: image)
                .resizable()
                .scaledToFit()
                .padding()

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.55))
                    .font(.system(size: 30))
            }
            .padding()
        }
        .onTapGesture(perform: onClose)
    }
}

private extension View {
    @ViewBuilder
    func tabBarHiddenIfAvailable() -> some View {
        #if os(iOS)
        self.toolbar(.hidden, for: .tabBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func navigationBarTitleDisplayModeIfAvailable() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func fullScreenCoverCompat<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        #if os(iOS)
        self.fullScreenCover(isPresented: isPresented, content: content)
        #else
        self.sheet(isPresented: isPresented, content: content)
        #endif
    }
}
