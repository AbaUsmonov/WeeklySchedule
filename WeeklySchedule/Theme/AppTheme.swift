//
//  AppTheme.swift
//  WeeklySchedule
//

import SwiftUI

enum AppTheme {

    /// A signature accent color per weekday, used for timeline dots, card edges and headers.
    static func accent(for day: Weekday) -> Color {
        switch day {
        case .monday: Color(hue: 0.62, saturation: 0.65, brightness: 0.92)
        case .tuesday: Color(hue: 0.50, saturation: 0.60, brightness: 0.80)
        case .wednesday: Color(hue: 0.09, saturation: 0.70, brightness: 0.95)
        case .thursday: Color(hue: 0.77, saturation: 0.55, brightness: 0.85)
        case .friday: Color(hue: 0.93, saturation: 0.60, brightness: 0.92)
        case .saturday: Color(hue: 0.36, saturation: 0.55, brightness: 0.75)
        }
    }

    static func gradient(for day: Weekday) -> LinearGradient {
        LinearGradient(
            colors: [accent(for: day), accent(for: day).opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardBackground: Color {
        #if os(iOS) || os(visionOS)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    static var pageBackground: Color {
        #if os(iOS) || os(visionOS)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    static let successColor = Color(hue: 0.36, saturation: 0.55, brightness: 0.70)
    static let warningColor = Color(hue: 0.09, saturation: 0.75, brightness: 0.95)
    static let vacantColor = Color(hue: 0.0, saturation: 0.0, brightness: 0.55)

    /// A stable, deterministic accent color per subject name (Swift's `hashValue` is
    /// randomized per process, so it can't be used here — this stays identical across launches).
    static func subjectAccent(for subject: String) -> Color {
        var hash: UInt64 = 5381
        for scalar in subject.unicodeScalars {
            hash = ((hash << 5) &+ hash) &+ UInt64(scalar.value)
        }
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.58, brightness: 0.80)
    }

    enum Metrics {
        static let cardCornerRadius: CGFloat = 20
        static let smallCornerRadius: CGFloat = 14
    }
}
