//
//  HomeworkListView.swift
//  WeeklySchedule
//

import SwiftUI

struct HomeworkListView: View {
    @EnvironmentObject private var homeworkStore: HomeworkStore

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(ScheduleData.allSubjects, id: \.self) { subject in
                        NavigationLink(value: subject) {
                            SubjectCard(
                                subject: subject,
                                pendingCount: homeworkStore.pendingCount(for: subject)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .background(AppTheme.pageBackground)
            .navigationDestination(for: String.self) { subject in
                SubjectHomeworkView(subject: subject)
            }
        }
    }
}

private struct SubjectCard: View {
    let subject: String
    let pendingCount: Int

    private var accent: Color { AppTheme.subjectAccent(for: subject) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: SubjectIcon.symbolName(for: subject))
                .font(.title2)
                .foregroundStyle(accent)

            Text(subject)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 8)

            if pendingCount > 0 {
                Text("\(pendingCount) активных")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accent, in: Capsule())
                    .foregroundStyle(.white)
            } else {
                Text("Пусто")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(minHeight: 130, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous))
    }
}
