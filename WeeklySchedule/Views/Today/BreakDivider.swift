//
//  BreakDivider.swift
//  WeeklySchedule
//

import SwiftUI

struct BreakDivider: View {
    let durationMinutes: Int
    let isActive: Bool
    let minutesLeft: Int?

    var body: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 2)
                .frame(width: 44, alignment: .center)
                .overlay(alignment: .center) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.caption2)
                        .foregroundStyle(isActive ? AppTheme.warningColor : .secondary)
                        .padding(6)
                        .background(isActive ? AppTheme.warningColor.opacity(0.18) : AppTheme.pageBackground, in: Circle())
                }

            HStack {
                Text(isActive ? "Перерыв — сейчас" : "Перерыв \(durationMinutes) мин")
                    .font(.caption.weight(isActive ? .bold : .medium))
                    .foregroundStyle(isActive ? AppTheme.warningColor : .secondary)

                if isActive, let minutesLeft {
                    Spacer()
                    Text("ещё \(minutesLeft) мин")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
        }
        .frame(height: 30)
    }
}
