//
//  TodayHeaderView.swift
//  WeeklySchedule
//

import SwiftUI

struct TodayHeaderView: View {
    let weekday: Weekday
    let date: Date
    let parity: WeekParity
    let isAutomaticParity: Bool
    let status: DayStatus
    let onTapParity: () -> Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(weekday.fullName)
                        .font(.largeTitle.weight(.bold))
                    Text(dateFormatter.string(from: date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onTapParity) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(parity.shortTitle)
                            .font(.subheadline.weight(.bold))
                        Text(isAutomaticParity ? "авто" : "вручную")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.accent(for: weekday).opacity(0.15), in: Capsule())
                    .foregroundStyle(AppTheme.accent(for: weekday))
                }
                .buttonStyle(.plain)
            }

            statusBanner
        }
    }

    @ViewBuilder
    private var statusBanner: some View {
        switch status {
        case .noClasses:
            statusRow(icon: "moon.zzz.fill", text: "Сегодня пар нет — можно выдохнуть", color: AppTheme.successColor)
        case .beforeFirst(let first, let minutesLeft):
            statusRow(icon: "sunrise.fill", text: "Первая пара в \(first.startTime) · через \(minutesLeft) мин", color: AppTheme.accent(for: weekday))
        case .inLesson(let lesson, let minutesLeft):
            statusRow(icon: "play.circle.fill", text: "Сейчас: \(lesson.subject) · ещё \(minutesLeft) мин", color: AppTheme.accent(for: weekday))
        case .onBreak(let next, let minutesLeft):
            statusRow(icon: "cup.and.saucer.fill", text: "Перерыв · «\(next.subject)» через \(minutesLeft) мин", color: AppTheme.warningColor)
        case .finished:
            statusRow(icon: "checkmark.seal.fill", text: "Занятия на сегодня окончены", color: AppTheme.successColor)
        }
    }

    private func statusRow(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .frame(height: 20)
            Text(text)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: AppTheme.Metrics.smallCornerRadius, style: .continuous))
    }
}
