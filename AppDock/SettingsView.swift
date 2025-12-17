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
