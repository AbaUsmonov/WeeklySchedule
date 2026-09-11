//
//  ContentView.swift
//  WeeklySchedule
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var scheduleStore: ScheduleStore
    @EnvironmentObject private var homeworkStore: HomeworkStore
    @EnvironmentObject private var appearanceStore: AppearanceStore
    @State private var selectedTab = 0
    @State private var importedSubject: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(onOpenHomework: { selectedTab = 2 })
                .tabItem { Label("Сегодня", systemImage: "book.pages.fill") }
                .tag(0)

            WeekView()
                .tabItem { Label("Неделя", systemImage: "calendar") }
                .tag(1)

            HomeworkListView()
                .tabItem { Label("Домашка", systemImage: "checklist") }
                .tag(2)
        }
        .environmentObject(scheduleStore)
        .environmentObject(homeworkStore)
        .environmentObject(appearanceStore)
        .onOpenURL { url in
            handleIncomingFile(url)
        }
        .alert("Задание добавлено", isPresented: Binding(
            get: { importedSubject != nil },
            set: { if !$0 { importedSubject = nil } }
        )) {
            Button("Ок") { importedSubject = nil }
        } message: {
            if let importedSubject {
                Text("«\(importedSubject)» появилось во вкладке «Домашка».")
            }
        }
    }

    private func handleIncomingFile(_ url: URL) {
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }

        guard let share = HomeworkShare.load(from: url) else { return }

        let image = homeworkStore.importShare(share)
        #if os(iOS)
        if let image {
            PhotoLibrarySaver.save(image)
        }
        #endif

        importedSubject = share.subject
        selectedTab = 2
    }
}

#Preview {
    ContentView()
        .environmentObject(ScheduleStore())
        .environmentObject(HomeworkStore())
        .environmentObject(AppearanceStore())
}
