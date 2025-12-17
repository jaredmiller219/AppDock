//
//  SettingsView.swift
//  AppDock
//

import SwiftUI

/// Simple settings surface for the menu bar app.
struct SettingsView: View {
    @AppStorage("settings.launchAtLogin") private var launchAtLogin = false
    @AppStorage("settings.openOnStartup") private var openOnStartup = true
    @AppStorage("settings.autoUpdates") private var autoUpdates = true
    @AppStorage("settings.showAppLabels") private var showAppLabels = true
    @AppStorage("settings.showRunningIndicator") private var showRunningIndicator = true
    @AppStorage("settings.enableHoverRemove") private var enableHoverRemove = true
    @AppStorage("settings.confirmBeforeQuit") private var confirmBeforeQuit = false
    @AppStorage("settings.keepQuitApps") private var keepQuitApps = true
    @AppStorage("settings.defaultFilter") private var defaultFilter: AppFilterOption = .all
    @AppStorage("settings.defaultSort") private var defaultSort: AppSortOption = .recent
    @AppStorage("settings.gridColumns") private var gridColumns = 3
    @AppStorage("settings.gridRows") private var gridRows = 4
    @AppStorage("settings.iconSize") private var iconSize = 64.0
    @AppStorage("settings.labelSize") private var labelSize = 8.0
    @AppStorage("settings.reduceMotion") private var reduceMotion = false
    @AppStorage("settings.debugLogging") private var debugLogging = false

    private func restoreDefaults() {
        launchAtLogin = false
        openOnStartup = true
        autoUpdates = true
        showAppLabels = true
        showRunningIndicator = true
        enableHoverRemove = true
        confirmBeforeQuit = false
        keepQuitApps = true
        defaultFilter = .all
        defaultSort = .recent
        gridColumns = 3
        gridRows = 4
        iconSize = 64
        labelSize = 8
        reduceMotion = false
        debugLogging = false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.title2)
                .bold()
            Text("Configure AppDock preferences.")
                .foregroundColor(.secondary)

            Form {
                Section("General") {
                    Toggle("Launch at login", isOn: $launchAtLogin)
                    Toggle("Open dock on startup", isOn: $openOnStartup)
                    Toggle("Check for updates automatically", isOn: $autoUpdates)
                }

                Section("Dock Layout") {
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

                Section("Filtering & Sorting") {
                    Picker("Default filter", selection: $defaultFilter) {
                        ForEach(AppFilterOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    Picker("Default sort order", selection: $defaultSort) {
                        ForEach(AppSortOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                }

                Section("Behavior") {
                    Toggle("Show app labels", isOn: $showAppLabels)
                    Toggle("Show running indicator", isOn: $showRunningIndicator)
                    Toggle("Enable hover remove button", isOn: $enableHoverRemove)
                    Toggle("Confirm before quitting apps", isOn: $confirmBeforeQuit)
                    Toggle("Keep apps after quit", isOn: $keepQuitApps)
                }

                Section("Accessibility") {
                    Toggle("Reduce motion", isOn: $reduceMotion)
                }

                Section("Advanced") {
                    Toggle("Enable debug logging", isOn: $debugLogging)
                    Button("Restore Defaults") {
                        restoreDefaults()
                    }
                }
            }
        }
        .padding(16)
        .frame(minWidth: 420, minHeight: 520, alignment: .topLeading)
    }
}

#Preview {
    SettingsView()
}
