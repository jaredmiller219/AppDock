//
//  SettingsFooterView.swift
//  AppDock
//

import SwiftUI

struct SettingsFooterView: View {
    let isApplyDisabled: Bool
    let onRestoreDefaults: () -> Void
    let onSaveDefault: () -> Void
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
