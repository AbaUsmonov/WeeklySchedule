//
//  WeekParitySettingsView.swift
//  WeeklySchedule
//

import SwiftUI

struct WeekParitySettingsView: View {
    @EnvironmentObject private var scheduleStore: ScheduleStore
    @EnvironmentObject private var appearanceStore: AppearanceStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        scheduleStore.resetToAutomatic()
                    } label: {
                        row(
                            title: "Определять автоматически",
                            subtitle: "По номеру недели в календаре",
                            isSelected: scheduleStore.isAutomatic
                        )
                    }

                    Button {
                        scheduleStore.setManual(.odd)
                    } label: {
                        row(
                            title: "Нечётная неделя",
                            subtitle: "1-й вариант расписания",
                            isSelected: scheduleStore.manualParity == .odd
                        )
                    }

                    Button {
                        scheduleStore.setManual(.even)
                    } label: {
                        row(
                            title: "Чётная неделя",
                            subtitle: "2-й вариант расписания",
                            isSelected: scheduleStore.manualParity == .even
                        )
                    }
                } header: {
                    Text("Какая сейчас неделя")
                } footer: {
                    Text("Если деканат считает недели не так, как календарь, выбери нужный вариант вручную — приложение запомнит выбор.")
                }

                Section {
                    ForEach(AppAppearance.allCases) { mode in
                        Button {
                            appearanceStore.appearance = mode
                        } label: {
                            HStack {
                                Image(systemName: mode.icon)
                                    .frame(width: 24)
                                    .foregroundStyle(mode == .dark ? .indigo : (mode == .light ? .orange : .secondary))
                                Text(mode.title)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if appearanceStore.appearance == mode {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                } header: {
                    Text("Тема оформления")
                } footer: {
                    Text("«Тёмная» держит тёмную тему всегда, даже если в системе включена светлая.")
                }
            }
            .navigationTitle("Настройки")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func row(title: String, subtitle: String, isSelected: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
    }
}
