//
//  SettingsSupport.swift
//  AppDock
//

import SwiftUI

/// Central place for settings keys, defaults, and reset helpers.
struct SettingsDefaults {
    static let launchAtLoginKey = "settings.launchAtLogin"
    static let openOnStartupKey = "settings.openOnStartup"
    static let autoUpdatesKey = "settings.autoUpdates"
    static let showAppLabelsKey = "settings.showAppLabels"
    static let showRunningIndicatorKey = "settings.showRunningIndicator"
    static let enableHoverRemoveKey = "settings.enableHoverRemove"
    static let confirmBeforeQuitKey = "settings.confirmBeforeQuit"
    static let keepQuitAppsKey = "settings.keepQuitApps"
    static let defaultFilterKey = "settings.defaultFilter"
    static let defaultSortKey = "settings.defaultSort"
    static let gridColumnsKey = "settings.gridColumns"
    static let gridRowsKey = "settings.gridRows"
    static let iconSizeKey = "settings.iconSize"
    static let labelSizeKey = "settings.labelSize"
    static let reduceMotionKey = "settings.reduceMotion"
    static let debugLoggingKey = "settings.debugLogging"
    static let menuPageKey = "settings.menuPage"
    static let simpleSettingsKey = "settings.simpleMode"
    static let menuLayoutModeKey = "settings.menuLayoutMode"

    static let launchAtLoginDefault = false
    static let openOnStartupDefault = true
    static let autoUpdatesDefault = true
    static let showAppLabelsDefault = true
    static let showRunningIndicatorDefault = true
    static let enableHoverRemoveDefault = true
    static let confirmBeforeQuitDefault = false
    static let keepQuitAppsDefault = true
    static let defaultFilterDefault: AppFilterOption = .all
    static let defaultSortDefault: AppSortOption = .recent
    static let gridColumnsDefault = 3
    static let gridRowsDefault = 4
    static let iconSizeDefault = 64.0
    static let labelSizeDefault = 8.0
    static let reduceMotionDefault = false
    static let debugLoggingDefault = false
    static let menuPageDefault: MenuPage = .dock
    static let simpleSettingsDefault = false
    static let menuLayoutModeDefault: MenuLayoutMode = .advanced

    static func defaultsDictionary() -> [String: Any] {
        [
            launchAtLoginKey: launchAtLoginDefault,
            openOnStartupKey: openOnStartupDefault,
            autoUpdatesKey: autoUpdatesDefault,
            showAppLabelsKey: showAppLabelsDefault,
            showRunningIndicatorKey: showRunningIndicatorDefault,
            enableHoverRemoveKey: enableHoverRemoveDefault,
            confirmBeforeQuitKey: confirmBeforeQuitDefault,
            keepQuitAppsKey: keepQuitAppsDefault,
            defaultFilterKey: defaultFilterDefault.rawValue,
            defaultSortKey: defaultSortDefault.rawValue,
            gridColumnsKey: gridColumnsDefault,
            gridRowsKey: gridRowsDefault,
            iconSizeKey: iconSizeDefault,
            labelSizeKey: labelSizeDefault,
            reduceMotionKey: reduceMotionDefault,
            debugLoggingKey: debugLoggingDefault,
            menuPageKey: menuPageDefault.rawValue,
            simpleSettingsKey: simpleSettingsDefault,
            menuLayoutModeKey: menuLayoutModeDefault.rawValue
        ]
    }

    static func restore(in defaults: UserDefaults = .standard) {
        defaultsDictionary().forEach { key, value in
            defaults.set(value, forKey: key)
        }
    }

    static func boolValue(forKey key: String, defaultValue: Bool, in defaults: UserDefaults = .standard) -> Bool {
        guard defaults.object(forKey: key) != nil else { return defaultValue }
        return defaults.bool(forKey: key)
    }

    static func intValue(forKey key: String, defaultValue: Int, in defaults: UserDefaults = .standard) -> Int {
        guard defaults.object(forKey: key) != nil else { return defaultValue }
        return defaults.integer(forKey: key)
    }

    static func doubleValue(forKey key: String, defaultValue: Double, in defaults: UserDefaults = .standard) -> Double {
        guard defaults.object(forKey: key) != nil else { return defaultValue }
        return defaults.double(forKey: key)
    }

    static func stringValue(forKey key: String, defaultValue: String, in defaults: UserDefaults = .standard) -> String {
        defaults.string(forKey: key) ?? defaultValue
    }

    static func menuPageValue(in defaults: UserDefaults = .standard) -> MenuPage {
        let rawValue = stringValue(
            forKey: menuPageKey,
            defaultValue: menuPageDefault.rawValue,
            in: defaults
        )
        return MenuPage(rawValue: rawValue) ?? menuPageDefault
    }

    static func menuLayoutModeValue(in defaults: UserDefaults = .standard) -> MenuLayoutMode {
        let rawValue = stringValue(
            forKey: menuLayoutModeKey,
            defaultValue: menuLayoutModeDefault.rawValue,
            in: defaults
        )
        return MenuLayoutMode(rawValue: rawValue) ?? menuLayoutModeDefault
    }
}

/// Staged settings values, applied to UserDefaults + AppState on demand.
struct SettingsDraft: Equatable {
    var launchAtLogin: Bool
    var openOnStartup: Bool
    var autoUpdates: Bool
    var showAppLabels: Bool
    var showRunningIndicator: Bool
    var enableHoverRemove: Bool
    var confirmBeforeQuit: Bool
    var keepQuitApps: Bool
    var defaultFilter: AppFilterOption
    var defaultSort: AppSortOption
    var gridColumns: Int
    var gridRows: Int
    var iconSize: Double
    var labelSize: Double
    var reduceMotion: Bool
    var debugLogging: Bool
    var simpleSettings: Bool
    var menuLayoutMode: MenuLayoutMode

    static func from(appState: AppState) -> SettingsDraft {
        SettingsDraft(
            launchAtLogin: appState.launchAtLogin,
            openOnStartup: appState.openOnStartup,
            autoUpdates: appState.autoUpdates,
            showAppLabels: appState.showAppLabels,
            showRunningIndicator: appState.showRunningIndicator,
            enableHoverRemove: appState.enableHoverRemove,
            confirmBeforeQuit: appState.confirmBeforeQuit,
            keepQuitApps: appState.keepQuitApps,
            defaultFilter: appState.filterOption,
            defaultSort: appState.sortOption,
            gridColumns: appState.gridColumns,
            gridRows: appState.gridRows,
            iconSize: appState.iconSize,
            labelSize: appState.labelSize,
            reduceMotion: appState.reduceMotion,
            debugLogging: appState.debugLogging,
            simpleSettings: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.simpleSettingsKey,
                defaultValue: SettingsDefaults.simpleSettingsDefault
            ),
            menuLayoutMode: appState.menuLayoutMode
        )
    }

    static func load(from defaults: UserDefaults = .standard) -> SettingsDraft {
        let defaultFilterRaw = SettingsDefaults.stringValue(
            forKey: SettingsDefaults.defaultFilterKey,
            defaultValue: SettingsDefaults.defaultFilterDefault.rawValue,
            in: defaults
        )
        let defaultSortRaw = SettingsDefaults.stringValue(
            forKey: SettingsDefaults.defaultSortKey,
            defaultValue: SettingsDefaults.defaultSortDefault.rawValue,
            in: defaults
        )

        return SettingsDraft(
            launchAtLogin: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.launchAtLoginKey,
                defaultValue: SettingsDefaults.launchAtLoginDefault,
                in: defaults
            ),
            openOnStartup: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.openOnStartupKey,
                defaultValue: SettingsDefaults.openOnStartupDefault,
                in: defaults
            ),
            autoUpdates: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.autoUpdatesKey,
                defaultValue: SettingsDefaults.autoUpdatesDefault,
                in: defaults
            ),
            showAppLabels: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.showAppLabelsKey,
                defaultValue: SettingsDefaults.showAppLabelsDefault,
                in: defaults
            ),
            showRunningIndicator: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.showRunningIndicatorKey,
                defaultValue: SettingsDefaults.showRunningIndicatorDefault,
                in: defaults
            ),
            enableHoverRemove: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.enableHoverRemoveKey,
                defaultValue: SettingsDefaults.enableHoverRemoveDefault,
                in: defaults
            ),
            confirmBeforeQuit: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.confirmBeforeQuitKey,
                defaultValue: SettingsDefaults.confirmBeforeQuitDefault,
                in: defaults
            ),
            keepQuitApps: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.keepQuitAppsKey,
                defaultValue: SettingsDefaults.keepQuitAppsDefault,
                in: defaults
            ),
            defaultFilter: AppFilterOption(rawValue: defaultFilterRaw) ?? SettingsDefaults.defaultFilterDefault,
            defaultSort: AppSortOption(rawValue: defaultSortRaw) ?? SettingsDefaults.defaultSortDefault,
            gridColumns: SettingsDefaults.intValue(
                forKey: SettingsDefaults.gridColumnsKey,
                defaultValue: SettingsDefaults.gridColumnsDefault,
                in: defaults
            ),
            gridRows: SettingsDefaults.intValue(
                forKey: SettingsDefaults.gridRowsKey,
                defaultValue: SettingsDefaults.gridRowsDefault,
                in: defaults
            ),
            iconSize: SettingsDefaults.doubleValue(
                forKey: SettingsDefaults.iconSizeKey,
                defaultValue: SettingsDefaults.iconSizeDefault,
                in: defaults
            ),
            labelSize: SettingsDefaults.doubleValue(
                forKey: SettingsDefaults.labelSizeKey,
                defaultValue: SettingsDefaults.labelSizeDefault,
                in: defaults
            ),
            reduceMotion: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.reduceMotionKey,
                defaultValue: SettingsDefaults.reduceMotionDefault,
                in: defaults
            ),
            debugLogging: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.debugLoggingKey,
                defaultValue: SettingsDefaults.debugLoggingDefault,
                in: defaults
            ),
            simpleSettings: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.simpleSettingsKey,
                defaultValue: SettingsDefaults.simpleSettingsDefault,
                in: defaults
            ),
            menuLayoutMode: SettingsDefaults.menuLayoutModeValue(in: defaults)
        )
    }

    /// Persist staged values into UserDefaults.
    func apply(to defaults: UserDefaults = .standard) {
        defaults.set(launchAtLogin, forKey: SettingsDefaults.launchAtLoginKey)
        defaults.set(openOnStartup, forKey: SettingsDefaults.openOnStartupKey)
        defaults.set(autoUpdates, forKey: SettingsDefaults.autoUpdatesKey)
        defaults.set(showAppLabels, forKey: SettingsDefaults.showAppLabelsKey)
        defaults.set(showRunningIndicator, forKey: SettingsDefaults.showRunningIndicatorKey)
        defaults.set(enableHoverRemove, forKey: SettingsDefaults.enableHoverRemoveKey)
        defaults.set(confirmBeforeQuit, forKey: SettingsDefaults.confirmBeforeQuitKey)
        defaults.set(keepQuitApps, forKey: SettingsDefaults.keepQuitAppsKey)
        defaults.set(defaultFilter.rawValue, forKey: SettingsDefaults.defaultFilterKey)
        defaults.set(defaultSort.rawValue, forKey: SettingsDefaults.defaultSortKey)
        defaults.set(gridColumns, forKey: SettingsDefaults.gridColumnsKey)
        defaults.set(gridRows, forKey: SettingsDefaults.gridRowsKey)
        defaults.set(iconSize, forKey: SettingsDefaults.iconSizeKey)
        defaults.set(labelSize, forKey: SettingsDefaults.labelSizeKey)
        defaults.set(reduceMotion, forKey: SettingsDefaults.reduceMotionKey)
        defaults.set(debugLogging, forKey: SettingsDefaults.debugLoggingKey)
        defaults.set(simpleSettings, forKey: SettingsDefaults.simpleSettingsKey)
        defaults.set(menuLayoutMode.rawValue, forKey: SettingsDefaults.menuLayoutModeKey)
    }
}

/// Neutral card styling for GroupBox sections.
struct CardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: AppDockConstants.CardStyle.spacing) {
            configuration.label
            configuration.content
        }
        .padding(AppDockConstants.CardStyle.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppDockConstants.CardStyle.cornerRadius)
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: AppDockConstants.CardStyle.cornerRadius)
                        .stroke(
                            Color.gray.opacity(AppDockConstants.CardStyle.strokeOpacity),
                            lineWidth: AppDockConstants.CardStyle.strokeLineWidth
                        )
                )
        )
        .shadow(
            color: Color.black.opacity(AppDockConstants.CardStyle.shadowOpacity),
            radius: AppDockConstants.CardStyle.shadowRadius,
            x: AppDockConstants.CardStyle.shadowOffsetX,
            y: AppDockConstants.CardStyle.shadowOffsetY
        )
    }
}
