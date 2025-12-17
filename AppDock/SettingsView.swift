//
//  SettingsView.swift
//  AppDock
//

import SwiftUI

/// Settings UI with staged changes and an explicit Apply action.
struct SettingsView: View {
    @ObservedObject var appState: AppState
    @State private var draft: SettingsDraft

    init(appState: AppState) {
        self.appState = appState
        _draft = State(initialValue: SettingsDraft.load())
    }

    private let accentColor: Color = .blue

    private func applySettings() {
        draft.apply()
        appState.applySettings(draft)
    }

    private func saveAsDefault() {
        draft.apply()
    }

    private func restoreDefaults() {
        SettingsDefaults.restore()
        draft = SettingsDraft.load()
        appState.applySettings(draft)
    }

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                        Image(systemName: "gearshape.2.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .frame(width: 38, height: 38)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(.title2)
                            .bold()
                        Text("Configure AppDock preferences.")
                            .foregroundColor(.secondary)
                    }
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        GroupBox("General") {
                            VStack(alignment: .leading, spacing: 10) {
                                Toggle("Launch at login", isOn: $draft.launchAtLogin)
                                Toggle("Open dock on startup", isOn: $draft.openOnStartup)
                                Toggle("Check for updates automatically", isOn: $draft.autoUpdates)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GroupBox("Dock Layout") {
                            VStack(alignment: .leading, spacing: 10) {
                                Stepper(value: $draft.gridColumns, in: 2...6) {
                                    HStack {
                                        Text("Columns")
                                        Spacer()
                                        Text("\(draft.gridColumns)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Stepper(value: $draft.gridRows, in: 2...8) {
                                    HStack {
                                        Text("Rows")
                                        Spacer()
                                        Text("\(draft.gridRows)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                HStack {
                                    Text("Icon size")
                                    Slider(value: $draft.iconSize, in: 32...96, step: 2)
                                    Text("\(Int(draft.iconSize))")
                                        .frame(width: 36, alignment: .trailing)
                                        .foregroundColor(.secondary)
                                }
                                HStack {
                                    Text("Label size")
                                    Slider(value: $draft.labelSize, in: 6...14, step: 1)
                                    Text("\(Int(draft.labelSize))")
                                        .frame(width: 36, alignment: .trailing)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GroupBox("Filtering & Sorting") {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Default filter")
                                    Spacer()
                                    Picker("", selection: $draft.defaultFilter) {
                                        ForEach(AppFilterOption.allCases) { option in
                                            Text(option.title).tag(option)
                                        }
                                    }
                                    .labelsHidden()
                                    .pickerStyle(.menu)
                                }
                                HStack {
                                    Text("Default sort order")
                                    Spacer()
                                    Picker("", selection: $draft.defaultSort) {
                                        ForEach(AppSortOption.allCases) { option in
                                            Text(option.title).tag(option)
                                        }
                                    }
                                    .labelsHidden()
                                    .pickerStyle(.menu)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GroupBox("Behavior") {
                            VStack(alignment: .leading, spacing: 10) {
                                Toggle("Show app labels", isOn: $draft.showAppLabels)
                                Toggle("Show running indicator", isOn: $draft.showRunningIndicator)
                                Toggle("Enable hover remove button", isOn: $draft.enableHoverRemove)
                                Toggle("Confirm before quitting apps", isOn: $draft.confirmBeforeQuit)
                                Toggle("Keep apps after quit", isOn: $draft.keepQuitApps)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GroupBox("Accessibility") {
                            VStack(alignment: .leading, spacing: 10) {
                                Toggle("Reduce motion", isOn: $draft.reduceMotion)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GroupBox("Advanced") {
                            VStack(alignment: .leading, spacing: 10) {
                                Toggle("Enable debug logging", isOn: $draft.debugLogging)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .tint(accentColor)
                .onAppear {
                    draft = SettingsDraft.load()
                }

                HStack {
                    Menu {
                        Button("Restore Defaults") {
                            restoreDefaults()
                        }
                        Button("Set as Default") {
                            saveAsDefault()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Settings Actions")

                    Spacer()

                    Button("Apply") {
                        applySettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(draft == SettingsDraft.from(appState: appState))
                }
            }
            .padding(20)
        }
        .groupBoxStyle(CardGroupBoxStyle())
        .frame(minWidth: 440, minHeight: 560, alignment: .topLeading)
    }
}

//#Preview {
//    SettingsView(appState: .init())
//}

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
            debugLoggingKey: debugLoggingDefault
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
            debugLogging: appState.debugLogging
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
            )
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
    }
}

/// Neutral card styling for GroupBox sections.
private struct CardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            configuration.label
            configuration.content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
