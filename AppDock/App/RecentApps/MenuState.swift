//
//  MenuState.swift
//  AppDock
//

import SwiftUI

/// Holds menu-specific state so menu navigation changes don't re-render the dock grid.
final class MenuState: ObservableObject {
    /// Currently selected menu page in advanced layout.
    @Published var menuPage = SettingsDefaults.menuPageDefault {
        didSet {
            UserDefaults.standard.set(menuPage.rawValue, forKey: SettingsDefaults.menuPageKey)
        }
    }

    init() {
        menuPage = SettingsDefaults.menuPageValue()
    }
}
