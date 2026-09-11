//
//  LessonCard.swift
//  WeeklySchedule
//

import SwiftUI

enum LessonCardState {
    case past
    case current(minutesLeft: Int)
    case upcoming
}

struct LessonCard: View {
    let lesson: Lesson
    let state: LessonCardState

    private var accent: Color { AppTheme.accent(for: lesson.weekday) }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timeColumn
            card
        }
        .opacity(isPast ? 0.55 : 1)
    }

    private var isPast: Bool {
        if case .past = state { return true }
        return false
    }

    private var isCurrent: Bool {
        if case .current = state { return true }
        return false
    }

    private var timeColumn: some View {
        VStack(spacing: 6) {
            Text(lesson.romanOrder)
                .font(.caption.weight(.bold))
                .foregroundStyle(isCurrent ? .white : .secondary)
                .frame(width: 26, height: 26)
                .background(isCurrent ? accent : Color.clear)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(accent.opacity(isPast ? 0.3 : 0.6), lineWidth: isCurrent ? 0 : 1.5)
                )

            Rectangle()
                .fill(accent.opacity(isPast ? 0.25 : 0.5))
                .frame(width: 2)
                .frame(maxHeight: .infinity)

            VStack(spacing: 1) {
                Text(lesson.startTime).font(.caption2.weight(.semibold))
                Text(lesson.endTime).font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .frame(width: 44)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lesson.subject)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if isCurrent, case .current(let minutesLeft) = state {
                    Label("\(minutesLeft) мин", systemImage: "clock.fill")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(accent, in: Capsule())
                        .foregroundStyle(.white)
                }
            }

            HStack(spacing: 12) {
                if let teacher = lesson.teacher {
                    Label(teacher, systemImage: "person.fill")
                        .foregroundStyle(lesson.isVacant ? AppTheme.vacantColor : .secondary)
                }
                if let room = lesson.room {
                    Label(room, systemImage: "door.left.hand.open")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)
            .lineLimit(1)

            if lesson.isJoint {
                Label("Поточная пара", systemImage: "person.3.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous)
                .stroke(isCurrent ? accent : Color.clear, lineWidth: 2)
        )
        .shadow(color: isCurrent ? accent.opacity(0.25) : .black.opacity(0.04), radius: isCurrent ? 10 : 4, y: 3)
    }
}
