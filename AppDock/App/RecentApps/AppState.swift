//
//  AppState.swift
//  AppDock
//

import SwiftUI
import Cocoa

// MARK: - App State

/// Shared state for the UI, published for SwiftUI bindings.
///
/// - Note: Values are hydrated from settings and updated as the app runs.
class AppState: ObservableObject {
    // MARK: Dock Entries
    /// Dock entry tuple shared across view and model logic.
    ///
    /// - Note: Icons are pre-sized to keep rendering cheap in the grid.
    typealias AppEntry = (name: String, bundleid: String, icon: NSImage)

    /// Recently launched/running applications shown in the dock grid.
    ///
    /// Each tuple contains:
    /// - name: The localized display name
    /// - bundleid: The bundle identifier
    /// - icon: A pre-sized application icon
    @Published var recentApps: [AppEntry] = []

    // MARK: Filters + Sorting

    /// Selected filter for the dock list.
    ///
    /// - Note: Drives the filter picker and persists through settings.
    @Published var filterOption: AppFilterOption = .all

    /// Selected sorting option for the dock list.
    ///
    /// - Note: Updates the dock ordering when changed.
    @Published var sortOption: AppSortOption = .recent

    // MARK: Settings Bindings

    // Settings-backed toggles and layout values for the dock UI.
    // Populated from `SettingsDefaults` and refreshed from `SettingsDraft`.
	
    /// Toggle for adding the app to login items.
    @Published var launchAtLogin = SettingsDefaults.launchAtLoginDefault
    /// Controls whether the app opens on user login.
    @Published var openOnStartup = SettingsDefaults.openOnStartupDefault
    /// Toggle for automatic update checks (if enabled).
    @Published var autoUpdates = SettingsDefaults.autoUpdatesDefault
    /// Toggle for showing labels under dock icons.
    @Published var showAppLabels = SettingsDefaults.showAppLabelsDefault
    /// Toggle for the running status dot on dock tiles.
    @Published var showRunningIndicator = SettingsDefaults.showRunningIndicatorDefault
    /// Toggle for enabling hover-to-remove behavior.
    @Published var enableHoverRemove = SettingsDefaults.enableHoverRemoveDefault
    /// Toggle for showing a confirmation before quitting apps.
    @Published var confirmBeforeQuit = SettingsDefaults.confirmBeforeQuitDefault
    /// Toggle for keeping apps listed after they quit.
    @Published var keepQuitApps = SettingsDefaults.keepQuitAppsDefault
    /// Number of columns in the dock grid.
    @Published var gridColumns = SettingsDefaults.gridColumnsDefault
    /// Number of rows in the dock grid.
    @Published var gridRows = SettingsDefaults.gridRowsDefault
    /// Icon size for dock tiles.
    @Published var iconSize = SettingsDefaults.iconSizeDefault
    /// Label font size for dock tiles.
    @Published var labelSize = SettingsDefaults.labelSizeDefault
    /// Toggle for reducing motion and animation.
    @Published var reduceMotion = SettingsDefaults.reduceMotionDefault
    /// Toggle for debug logging output.
    @Published var debugLogging = SettingsDefaults.debugLoggingDefault
    /// Layout mode for the menu popover (simple vs. advanced).
    @Published var menuLayoutMode = SettingsDefaults.menuLayoutModeDefault {
        didSet {
            UserDefaults.standard.set(menuLayoutMode.rawValue, forKey: SettingsDefaults.menuLayoutModeKey)
        }
    }
    /// Currently selected menu page in advanced layout.
    @Published var menuPage = SettingsDefaults.menuPageDefault {
        didSet {
            UserDefaults.standard.set(menuPage.rawValue, forKey: SettingsDefaults.menuPageKey)
        }
    }

    // MARK: Initialization

    /// Initializes state from stored settings.
    ///
    /// - Note: Reads persisted values and applies them to the live state.
    init() {
        menuPage = SettingsDefaults.menuPageValue()
        menuLayoutMode = SettingsDefaults.menuLayoutModeValue()
        applySettings(SettingsDraft.load())
    }

    // MARK: Apply Settings

    /// Applies a full settings snapshot to the live state.
    ///
    /// - Note: Keeps UI bindings and persisted values in sync.
    func applySettings(_ settings: SettingsDraft) {
        launchAtLogin = settings.launchAtLogin
        openOnStartup = settings.openOnStartup
        autoUpdates = settings.autoUpdates
        showAppLabels = settings.showAppLabels
        showRunningIndicator = settings.showRunningIndicator
        enableHoverRemove = settings.enableHoverRemove
        confirmBeforeQuit = settings.confirmBeforeQuit
        keepQuitApps = settings.keepQuitApps
        filterOption = settings.defaultFilter
        sortOption = settings.defaultSort
        gridColumns = settings.gridColumns
        gridRows = settings.gridRows
        iconSize = settings.iconSize
        labelSize = settings.labelSize
        reduceMotion = settings.reduceMotion
        debugLogging = settings.debugLogging
        menuLayoutMode = settings.menuLayoutMode
    }
}
