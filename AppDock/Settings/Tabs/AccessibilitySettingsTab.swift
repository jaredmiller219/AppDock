//
//  AccessibilitySettingsTab.swift
//  AppDock
//

import SwiftUI

struct AccessibilitySettingsTab: View {
    @Binding var draft: SettingsDraft

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("Accessibility") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Toggle("Reduce motion", isOn: $draft.reduceMotion)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("SettingsTab-Accessibility")
        .padding(.top, AppDockConstants.SettingsLayout.sectionTopPadding)
    }
}
