//
//  TodayView.swift
//  WeeklySchedule
//

import SwiftUI

struct TodayView: View {
    var onOpenHomework: () -> Void = {}

    @EnvironmentObject private var scheduleStore: ScheduleStore
    @EnvironmentObject private var homeworkStore: HomeworkStore
    @EnvironmentObject private var appearanceStore: AppearanceStore
    @State private var showParitySheet = false

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 30)) { context in
                let now = context.date
                let weekday = Weekday(date: now)
                let parity = scheduleStore.currentParity(on: now)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if let weekday {
                            TodayHeaderView(
                                weekday: weekday,
                                date: now,
                                parity: parity,
                                isAutomaticParity: scheduleStore.isAutomatic,
                                status: DayStatusCalculator.status(for: ScheduleData.lessons(for: weekday, parity: parity), now: now),
                                onTapParity: { showParitySheet = true }
                            )

                            timeline(for: weekday, parity: parity, now: now)
                        } else {
                            sundayState
                        }
                    }
                    .padding(16)
                }
                .background(AppTheme.pageBackground)
                .navigationBarHiddenIfAvailable()
            }
            .sheet(isPresented: $showParitySheet) {
                WeekParitySettingsView()
                    .environmentObject(scheduleStore)
                    .environmentObject(appearanceStore)
                    .preferredColorScheme(appearanceStore.appearance.colorScheme)
            }
        }
    }

    @ViewBuilder
    private func timeline(for weekday: Weekday, parity: WeekParity, now: Date) -> some View {
        let lessons = ScheduleData.lessons(for: weekday, parity: parity)
        let status = DayStatusCalculator.status(for: lessons, now: now)

        if lessons.isEmpty {
            emptyDayCard
        } else {
            VStack(spacing: 0) {
                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                    LessonCard(lesson: lesson, state: cardState(for: lesson, status: status))

                    if index < lessons.count - 1 {
                        let next = lessons[index + 1]
                        BreakDivider(
                            durationMinutes: breakMinutes(from: lesson, to: next),
                            isActive: isBreakActive(status: status, after: lesson, before: next),
                            minutesLeft: breakMinutesLeft(status: status, before: next)
                        )
                    }
                }
            }

            if case .finished = status {
                let subjectsTomorrow = subjects(on: Calendar.current.date(byAdding: .day, value: 1, to: now)!)
                let pendingTasks = homeworkStore.pendingTasks(forSubjects: subjectsTomorrow)

                AfterClassesCard(
                    pendingTasks: pendingTasks,
                    hasClassesTomorrow: !subjectsTomorrow.isEmpty,
                    onOpenHomework: onOpenHomework
                )
                .padding(.top, 8)
            }
        }
    }

    /// Distinct subjects taught on the given date, in schedule order, accounting for odd/even week.
    private func subjects(on date: Date) -> [String] {
        guard let weekday = Weekday(date: date) else { return [] }
        let parity = scheduleStore.parity(on: date)
        var seen = Set<String>()
        return ScheduleData.lessons(for: weekday, parity: parity)
            .map(\.subject)
            .filter { seen.insert($0).inserted }
    }

    private func cardState(for lesson: Lesson, status: DayStatus) -> LessonCardState {
        switch status {
        case .inLesson(let current, let minutesLeft) where current.id == lesson.id:
            return .current(minutesLeft: minutesLeft)
        case .inLesson(let current, _):
            return current.order > lesson.order ? .past : .upcoming
        case .onBreak(let next, _):
            return lesson.order < next.order ? .past : .upcoming
        case .finished:
            return .past
        case .beforeFirst, .noClasses:
            return .upcoming
        }
    }

    private func breakMinutes(from a: Lesson, to b: Lesson) -> Int {
        guard let end = a.endDate(on: Date()), let start = b.startDate(on: Date()) else { return 0 }
        return max(0, Int(start.timeIntervalSince(end) / 60))
    }

    private func isBreakActive(status: DayStatus, after: Lesson, before: Lesson) -> Bool {
        if case .onBreak(let next, _) = status, next.id == before.id { return true }
        return false
    }

    private func breakMinutesLeft(status: DayStatus, before: Lesson) -> Int? {
        if case .onBreak(let next, let minutesLeft) = status, next.id == before.id { return minutesLeft }
        return nil
    }

    private var emptyDayCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Сегодня занятий нет")
                .font(.headline)
            Text("Отличный день, чтобы разобрать домашку заранее.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous))
    }

    private var sundayState: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Воскресенье — выходной")
                .font(.headline)
            Text("Занятий по расписанию нет. Загляни во вкладку «Неделя», чтобы подготовиться к понедельнику.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous))
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
