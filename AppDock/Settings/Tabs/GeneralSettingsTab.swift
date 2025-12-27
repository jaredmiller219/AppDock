//
//  GeneralSettingsTab.swift
//  AppDock
//

import SwiftUI

struct GeneralSettingsTab: View {
    @Binding var draft: SettingsDraft

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("General") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Toggle("Launch at login", isOn: $draft.launchAtLogin)
                    Toggle("Open dock on startup", isOn: $draft.openOnStartup)
                    Toggle("Check for updates automatically", isOn: $draft.autoUpdates)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-General")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}
