/*
 SettingsFooterView.swift
 AppDock

 PURPOSE:
 This view displays the action buttons at the bottom of the Settings window.
 Provides controls for applying changes, restoring defaults, and saving defaults.

 OVERVIEW:
 SettingsFooterView contains:
 - More menu (ellipsis) with "Restore Defaults" and "Set as Default" options
 - "Apply" button (highlighted, disabled when no changes)
 - Spacer to right-align the Apply button

 Disabled state is controlled via isApplyDisabled flag and opacity is reduced.

 CALLBACKS:
 - onRestoreDefaults: Reset all settings to factory defaults
 - onSaveDefault: Persist current draft settings as default preference
 - onApply: Apply staged SettingsDraft changes to AppState and UserDefaults
*/

import SwiftUI

/// Action buttons footer for Settings window.
///
/// Provides controls for Apply, Restore Defaults, and Set as Default options.
/// Apply button is prominent and disabled when no changes have been made.
struct SettingsFooterView: View {
    /// Whether Apply button should be disabled (no pending changes)
    let isApplyDisabled: Bool

    /// Callback to reset all settings to factory defaults
    let onRestoreDefaults: () -> Void

    /// Callback to save current draft settings as default preference
    let onSaveDefault: () -> Void

    /// Callback to apply staged settings to AppState and UserDefaults
    let onApply: () -> Void

    var body: some View {
        HStack {
            Menu {
                Button("Restore Defaults") {
                    onRestoreDefaults()
                }
                Button("Set as Default") {
                    onSaveDefault()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .accessibilityLabel("Settings Actions")

            Spacer()

            Button("Apply") {
                onApply()
            }
            .buttonStyle(.borderedProminent)
            .tint(isApplyDisabled ? .gray : .accentColor)
            .opacity(isApplyDisabled ? 0.6 : 1)
            .disabled(isApplyDisabled)
        }
    }
}
