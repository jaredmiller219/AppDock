//
//  SettingsView.swift
//  AppDock
//

import SwiftUI

/// Simple settings surface for the menu bar app.
struct SettingsView: View {
    private let accent = Color(red: 0.18, green: 0.47, blue: 0.45)
    private let cardBackground = Color(red: 0.98, green: 0.98, blue: 0.99)

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
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.95, blue: 0.90),
                    Color(red: 0.92, green: 0.97, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(accent.opacity(0.15))
                        Image(systemName: "gearshape.2.fill")
                            .foregroundColor(accent)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .frame(width: 38, height: 38)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(.custom("Avenir Next", size: 22).weight(.bold))
                        Text("Tune the dock to feel like yours.")
                            .foregroundColor(.secondary)
                            .font(.custom("Avenir Next", size: 13))
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
                                .buttonStyle(.borderedProminent)
                                .tint(accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
        }
        .tint(accent)
        .groupBoxStyle(CardGroupBoxStyle(accent: accent, background: cardBackground))
        .frame(minWidth: 440, minHeight: 560, alignment: .topLeading)
    }
}

//#Preview {
//    SettingsView()
//}

private struct CardGroupBoxStyle: GroupBoxStyle {
    let accent: Color
    let background: Color

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            configuration.label
                .font(.custom("Avenir Next", size: 13).weight(.semibold))
                .foregroundColor(accent)
            configuration.content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(background)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accent.opacity(0.14), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
