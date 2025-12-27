//
//  AdvancedSettingsTab.swift
//  AppDock
//

import SwiftUI

struct AdvancedSettingsTab: View {
    @Binding var draft: SettingsDraft
    private var useAdvancedLayout: Binding<Bool> {
        Binding(
            get: { !draft.simpleSettings },
            set: { draft.simpleSettings = !$0 }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionSpacing) {
            GroupBox("Advanced") {
                VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sectionInnerSpacing) {
                    Toggle("Use advanced settings layout", isOn: useAdvancedLayout)
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
