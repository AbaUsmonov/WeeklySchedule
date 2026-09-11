//
//  WeeklyScheduleApp.swift
//  WeeklySchedule
//

import SwiftUI

@main
struct WeeklyScheduleApp: App {
    @StateObject private var scheduleStore = ScheduleStore()
    @StateObject private var homeworkStore = HomeworkStore()
    @StateObject private var appearanceStore = AppearanceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scheduleStore)
                .environmentObject(homeworkStore)
                .environmentObject(appearanceStore)
                .preferredColorScheme(appearanceStore.appearance.colorScheme)
        }
    }
}
