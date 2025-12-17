//
//  SettingsView.swift
//  AppDock
//

import SwiftUI

/// Simple settings surface for the menu bar app.
struct SettingsView: View {
    @AppStorage(SettingsDefaults.launchAtLoginKey)
    private var launchAtLogin = SettingsDefaults.launchAtLoginDefault
    @AppStorage(SettingsDefaults.openOnStartupKey)
    private var openOnStartup = SettingsDefaults.openOnStartupDefault
    @AppStorage(SettingsDefaults.autoUpdatesKey)
    private var autoUpdates = SettingsDefaults.autoUpdatesDefault
    @AppStorage(SettingsDefaults.showAppLabelsKey)
    private var showAppLabels = SettingsDefaults.showAppLabelsDefault
    @AppStorage(SettingsDefaults.showRunningIndicatorKey)
    private var showRunningIndicator = SettingsDefaults.showRunningIndicatorDefault
    @AppStorage(SettingsDefaults.enableHoverRemoveKey)
    private var enableHoverRemove = SettingsDefaults.enableHoverRemoveDefault
    @AppStorage(SettingsDefaults.confirmBeforeQuitKey)
    private var confirmBeforeQuit = SettingsDefaults.confirmBeforeQuitDefault
    @AppStorage(SettingsDefaults.keepQuitAppsKey)
    private var keepQuitApps = SettingsDefaults.keepQuitAppsDefault
    @AppStorage(SettingsDefaults.defaultFilterKey)
    private var defaultFilter: AppFilterOption = SettingsDefaults.defaultFilterDefault
    @AppStorage(SettingsDefaults.defaultSortKey)
    private var defaultSort: AppSortOption = SettingsDefaults.defaultSortDefault
    @AppStorage(SettingsDefaults.accentColorKey)
    private var accentColorRaw = SettingsDefaults.accentColorDefault
    @AppStorage(SettingsDefaults.gridColumnsKey)
    private var gridColumns = SettingsDefaults.gridColumnsDefault
    @AppStorage(SettingsDefaults.gridRowsKey)
    private var gridRows = SettingsDefaults.gridRowsDefault
    @AppStorage(SettingsDefaults.iconSizeKey)
    private var iconSize = SettingsDefaults.iconSizeDefault
    @AppStorage(SettingsDefaults.labelSizeKey)
    private var labelSize = SettingsDefaults.labelSizeDefault
    @AppStorage(SettingsDefaults.reduceMotionKey)
    private var reduceMotion = SettingsDefaults.reduceMotionDefault
    @AppStorage(SettingsDefaults.debugLoggingKey)
    private var debugLogging = SettingsDefaults.debugLoggingDefault

    private var accentColor: Color {
        SettingsAccentColor(rawValue: accentColorRaw)?.color ?? SettingsAccentColor.defaultColor
    }

    private func restoreDefaults() {
        SettingsDefaults.restore()
        launchAtLogin = SettingsDefaults.launchAtLoginDefault
        openOnStartup = SettingsDefaults.openOnStartupDefault
        autoUpdates = SettingsDefaults.autoUpdatesDefault
        showAppLabels = SettingsDefaults.showAppLabelsDefault
        showRunningIndicator = SettingsDefaults.showRunningIndicatorDefault
        enableHoverRemove = SettingsDefaults.enableHoverRemoveDefault
        confirmBeforeQuit = SettingsDefaults.confirmBeforeQuitDefault
        keepQuitApps = SettingsDefaults.keepQuitAppsDefault
        defaultFilter = SettingsDefaults.defaultFilterDefault
        defaultSort = SettingsDefaults.defaultSortDefault
        accentColorRaw = SettingsDefaults.accentColorDefault
        gridColumns = SettingsDefaults.gridColumnsDefault
        gridRows = SettingsDefaults.gridRowsDefault
        iconSize = SettingsDefaults.iconSizeDefault
        labelSize = SettingsDefaults.labelSizeDefault
        reduceMotion = SettingsDefaults.reduceMotionDefault
        debugLogging = SettingsDefaults.debugLoggingDefault
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
                                Toggle("Launch at login", isOn: $launchAtLogin)
                                Toggle("Open dock on startup", isOn: $openOnStartup)
                                Toggle("Check for updates automatically", isOn: $autoUpdates)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GroupBox("Appearance") {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Accent color")
                                    Spacer()
                                    Picker("", selection: $accentColorRaw) {
                                        ForEach(SettingsAccentColor.allCases) { option in
                                            Text(option.title).tag(option.rawValue)
                                        }
                                    }
                                    .labelsHidden()
                                    .pickerStyle(.menu)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GroupBox("Dock Layout") {
                            VStack(alignment: .leading, spacing: 10) {
                                Stepper(value: $gridColumns, in: 2...6) {
                                    HStack {
                                        Text("Columns")
                                        Spacer()
                                        Text("\(gridColumns)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Stepper(value: $gridRows, in: 2...8) {
                                    HStack {
                                        Text("Rows")
                                        Spacer()
                                        Text("\(gridRows)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                HStack {
                                    Text("Icon size")
                                    Slider(value: $iconSize, in: 32...96, step: 2)
                                    Text("\(Int(iconSize))")
                                        .frame(width: 36, alignment: .trailing)
                                        .foregroundColor(.secondary)
                                }
                                HStack {
                                    Text("Label size")
                                    Slider(value: $labelSize, in: 6...14, step: 1)
                                    Text("\(Int(labelSize))")
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
                                    Picker("", selection: $defaultFilter) {
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
                                    Picker("", selection: $defaultSort) {
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
                                Toggle("Show app labels", isOn: $showAppLabels)
                                Toggle("Show running indicator", isOn: $showRunningIndicator)
                                Toggle("Enable hover remove button", isOn: $enableHoverRemove)
                                Toggle("Confirm before quitting apps", isOn: $confirmBeforeQuit)
                                Toggle("Keep apps after quit", isOn: $keepQuitApps)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GroupBox("Accessibility") {
                            VStack(alignment: .leading, spacing: 10) {
                                Toggle("Reduce motion", isOn: $reduceMotion)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GroupBox("Advanced") {
                            VStack(alignment: .leading, spacing: 10) {
                                Toggle("Enable debug logging", isOn: $debugLogging)
                                Button("Restore Defaults") {
                                    restoreDefaults()
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .tint(accentColor)
            }
            .padding(20)
        }
        .groupBoxStyle(CardGroupBoxStyle())
        .frame(minWidth: 440, minHeight: 560, alignment: .topLeading)
    }
}

//#Preview {
//    SettingsView()
//}

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
    static let accentColorKey = "settings.accentColor"
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
    static let accentColorDefault = SettingsAccentColor.teal.rawValue
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
            accentColorKey: accentColorDefault,
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
}

enum SettingsAccentColor: String, CaseIterable, Identifiable {
    case blue
    case teal
    case orange
    case pink
    case graphite

    var id: String { rawValue }

    var title: String {
        switch self {
        case .blue:
            return "Blue"
        case .teal:
            return "Teal"
        case .orange:
            return "Orange"
        case .pink:
            return "Pink"
        case .graphite:
            return "Graphite"
        }
    }

    var color: Color {
        switch self {
        case .blue:
            return .blue
        case .teal:
            return .teal
        case .orange:
            return .orange
        case .pink:
            return .pink
        case .graphite:
            return .gray
        }
    }

    static var defaultColor: Color { SettingsAccentColor.teal.color }
}

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
