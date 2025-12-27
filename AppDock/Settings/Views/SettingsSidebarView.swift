//
//  SettingsSidebarView.swift
//  AppDock
//

import SwiftUI

struct SettingsSidebarView: View {
    @Binding var selectedTab: SettingsTab

    var body: some View {
        VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.sidebarSpacing) {
            ForEach(SettingsTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    HStack(spacing: AppDockConstants.SettingsLayout.tabRowSpacing) {
                        Image(systemName: tab.systemImage)
                            .frame(width: AppDockConstants.SettingsLayout.tabIconWidth)
                        Text(tab.title)
                        Spacer()
                    }
                    .padding(.vertical, AppDockConstants.SettingsLayout.tabButtonPaddingVertical)
                    .padding(.horizontal, AppDockConstants.SettingsLayout.tabButtonPaddingHorizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: AppDockConstants.SettingsLayout.tabButtonCornerRadius)
                            .fill(selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .frame(width: AppDockConstants.SettingsUI.sidebarWidth)
    }
}
