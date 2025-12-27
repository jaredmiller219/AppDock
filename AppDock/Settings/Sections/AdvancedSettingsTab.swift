//
//  AdvancedSettingsTab.swift
//  AppDock
//

import SwiftUI

struct AdvancedSettingsTab: View {
    @Binding var draft: SettingsDraft

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("Advanced") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Toggle("Enable debug logging", isOn: $draft.debugLogging)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-Advanced")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}
