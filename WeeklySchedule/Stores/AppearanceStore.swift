//
//  AppearanceStore.swift
//  WeeklySchedule
//

import Foundation
import Combine

@MainActor
final class AppearanceStore: ObservableObject {

    @Published var appearance: AppAppearance {
        didSet { defaults.set(appearance.rawValue, forKey: key) }
    }

    private let defaults = UserDefaults.standard
    private let key = "appearance.mode"

    init() {
        if let raw = defaults.string(forKey: key), let saved = AppAppearance(rawValue: raw) {
            appearance = saved
        } else {
            appearance = .system
        }
    }
}
