/*
 SettingsSidebarView.swift
 AppDock

 PURPOSE:
 This view displays the left sidebar navigation for the Settings window.
 Allows users to select which settings tab to view.

 OVERVIEW:
 SettingsSidebarView renders:
 - Vertical list of SettingsTab options
 - Button for each tab with icon and title
 - Accent color highlight for selected tab
 - Fixed width sidebar matching Settings UI layout

 When a tab button is tapped, it updates selectedTab binding to switch views.

 STYLING:
 - Left alignment for vertical tab layout
 - Rounded rectangle background highlight for selected tab
 - Icon and text spacing consistent with design system
 - Vertical spacer at bottom for visual balance
*/

import SwiftUI

/// Left sidebar navigation for Settings window tab selection.
///
/// Displays list of settings tabs (General, Layout, Filtering, etc.) with visual
/// highlighting of the currently selected tab. Updates selectedTab binding when tapped.
struct SettingsSidebarView: View {
    /// Binding to currently selected settings tab
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
