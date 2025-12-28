//
//  MenuState.swift
//  AppDock
//
/*
 MenuState.swift

 Purpose:
  - Small observable container for popover-specific UI state (current page)
    that is intentionally separated from the heavier `AppState` so that
    switching pages does not force a re-render of the dock grid.
*/

import SwiftUI

/// Holds menu-specific state so menu navigation changes don't re-render the dock grid.
final class MenuState: ObservableObject {
    /// Currently selected menu page in advanced layout.
    ///
    /// - Persisted: Changes are written to `UserDefaults` via `SettingsDefaults`.
    @Published var menuPage = SettingsDefaults.menuPageDefault {
        didSet {
            UserDefaults.standard.set(menuPage.rawValue, forKey: SettingsDefaults.menuPageKey)
        }
    }

    init() {
        menuPage = SettingsDefaults.menuPageValue()
    }
}
