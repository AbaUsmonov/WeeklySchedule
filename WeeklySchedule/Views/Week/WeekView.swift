//
//  WeekView.swift
//  WeeklySchedule
//

import SwiftUI

struct WeekView: View {
    @EnvironmentObject private var scheduleStore: ScheduleStore
    @State private var browsingParity: WeekParity = .odd
    @State private var didInitParity = false

    private var todayWeekday: Weekday? { Weekday(date: Date()) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Неделя")
                        .font(.largeTitle.weight(.bold))

                    parityPicker

                    ForEach(Weekday.allCases) { day in
                        DaySection(
                            day: day,
                            lessons: ScheduleData.lessons(for: day, parity: browsingParity),
                            isToday: day == todayWeekday && browsingParity == scheduleStore.currentParity()
                        )
                    }
                }
                .padding(16)
            }
            .background(AppTheme.pageBackground)
            .navigationBarHiddenIfAvailable()
            .onAppear {
                guard !didInitParity else { return }
                browsingParity = scheduleStore.currentParity()
                didInitParity = true
            }
        }
    }

    private var parityPicker: some View {
        Picker("Неделя", selection: $browsingParity) {
            Text("Нечётная").tag(WeekParity.odd)
            Text("Чётная").tag(WeekParity.even)
        }
        .pickerStyle(.segmented)
    }
}

private extension View {
    @ViewBuilder
    func navigationBarHiddenIfAvailable() -> some View {
        #if os(iOS)
        self.toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }
}

private struct DaySection: View {
    let day: Weekday
    let lessons: [Lesson]
    let isToday: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(day.fullName)
                    .font(.title3.weight(.bold))
                if isToday {
                    Text("Сегодня")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.accent(for: day), in: Capsule())
                        .foregroundStyle(.white)
                }
                Spacer()
            }

            if lessons.isEmpty {
                Text("Занятий нет")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 6)
            } else {
                VStack(spacing: 8) {
                    ForEach(lessons) { lesson in
                        WeekLessonRow(lesson: lesson, accent: AppTheme.accent(for: day))
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous)
                .stroke(isToday ? AppTheme.accent(for: day).opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
    }
}

private struct WeekLessonRow: View {
    let lesson: Lesson
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 2) {
                Text(lesson.romanOrder).font(.caption.weight(.bold))
                Text(lesson.startTime).font(.caption2)
            }
            .foregroundStyle(accent)
            .frame(width: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.subject)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 6) {
                    if let teacher = lesson.teacher {
                        Text(teacher)
                            .foregroundStyle(lesson.isVacant ? AppTheme.vacantColor : .secondary)
                    }
                    if let room = lesson.room {
                        Text("· ауд. \(room)")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
                .lineLimit(1)
            }

            Spacer()
        }
    }
}
