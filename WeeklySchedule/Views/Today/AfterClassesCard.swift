//
//  AfterClassesCard.swift
//  WeeklySchedule
//

import SwiftUI

struct AfterClassesCard: View {
    let pendingTasks: [HomeworkTask]
    let hasClassesTomorrow: Bool
    let onOpenHomework: () -> Void

    private var isAllClear: Bool { pendingTasks.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(isAllClear ? AppTheme.successColor : AppTheme.warningColor)

                Text(titleText)
                    .font(.headline)
            }

            if !hasClassesTomorrow {
                Text("По расписанию завтра пар нет. Можно спокойно отдохнуть.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if isAllClear {
                Text("К завтрашним парам всё готово. Можно отдыхать.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Не забудь про задания к завтрашним парам:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(pendingTasks.prefix(3)) { task in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "circle")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.warningColor)
                                .padding(.top, 3)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(task.subject)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Text(task.text)
                                    .font(.subheadline)
                            }
                        }
                    }
                }

                if pendingTasks.count > 3 {
                    Text("и ещё \(pendingTasks.count - 3)…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if hasClassesTomorrow {
                Button(action: onOpenHomework) {
                    Label(isAllClear ? "Открыть домашние задания" : "Разобрать домашку", systemImage: "arrow.right.circle.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(isAllClear ? AppTheme.successColor : AppTheme.warningColor)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous))
    }

    private var iconName: String {
        if !hasClassesTomorrow { return "moon.stars.fill" }
        return isAllClear ? "checkmark.seal.fill" : "book.closed.fill"
    }

    private var titleText: String {
        if !hasClassesTomorrow { return "Занятия окончены" }
        return isAllClear ? "Занятия окончены" : "Занятия окончены, есть домашка"
    }
}
