//
//  SettingsView.swift
//  AppDock
//

import SwiftUI

/// Settings UI with staged changes and an explicit Apply action.
struct SettingsView: View {
    @ObservedObject var appState: AppState
    @State private var draft: SettingsDraft
    @State private var selectedTab: SettingsTab = .general
    @State private var appliedSimpleSettings: Bool

    init(appState: AppState) {
        self.appState = appState
        // Load staged values from UserDefaults when the settings UI is created.
        _draft = State(initialValue: SettingsDraft.load())
        _appliedSimpleSettings = State(
            initialValue: SettingsDefaults.boolValue(
                forKey: SettingsDefaults.simpleSettingsKey,
                defaultValue: SettingsDefaults.simpleSettingsDefault
            )
        )
    }

    private let accentColor: Color = .blue

    /// Writes draft values to disk and applies them immediately to the live UI.
    private func applySettings() {
        draft.apply()
        appState.applySettings(draft)
        appliedSimpleSettings = draft.simpleSettings
        NotificationCenter.default.post(name: .appDockShortcutsChanged, object: nil)
    }

    /// Persists draft values without changing the live in-memory settings.
    private func saveAsDefault() {
        draft.apply()
    }

    /// Restores default values, updates the draft, and refreshes the live state.
    private func restoreDefaults() {
        SettingsDefaults.restore()
        draft = SettingsDraft.load()
        appState.applySettings(draft)
        appliedSimpleSettings = draft.simpleSettings
        NotificationCenter.default.post(name: .appDockShortcutsChanged, object: nil)
    }

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.contentSpacing) {
                SettingsHeaderView()

                HStack(spacing: AppDockConstants.SettingsLayout.contentColumnSpacing) {
                    if !appliedSimpleSettings {
                        SettingsSidebarView(selectedTab: $selectedTab)
                    }

                    SettingsContentView(
                        appliedSimpleSettings: appliedSimpleSettings,
                        draft: $draft,
                        selectedTab: $selectedTab
                    )
                }
                .frame(maxHeight: .infinity, alignment: .topLeading)
                .tint(accentColor)
                .onAppear {
                    draft = SettingsDraft.load()
                    appliedSimpleSettings = SettingsDefaults.boolValue(
                        forKey: SettingsDefaults.simpleSettingsKey,
                        defaultValue: SettingsDefaults.simpleSettingsDefault
                    )
                }

                SettingsFooterView(
                    isApplyDisabled: draft == SettingsDraft.from(appState: appState),
                    onRestoreDefaults: restoreDefaults,
                    onSaveDefault: saveAsDefault,
                    onApply: applySettings
                )
            }
            .padding(AppDockConstants.SettingsLayout.rootPadding)
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
        .groupBoxStyle(CardGroupBoxStyle())
        .frame(
            minWidth: AppDockConstants.SettingsUI.minWidth,
            minHeight: AppDockConstants.SettingsUI.minHeight,
            alignment: .topLeading
        )
    }
}
