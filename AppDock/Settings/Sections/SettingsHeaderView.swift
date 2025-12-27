//
//  SettingsHeaderView.swift
//  AppDock
//

import SwiftUI

struct SettingsHeaderView: View {
    var body: some View {
        HStack(spacing: AppDockConstants.SettingsLayout.headerSpacing) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.15))
                Image(systemName: "gearshape.2.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: AppDockConstants.SettingsLayout.headerIconFontSize, weight: .semibold))
            }
            .frame(
                width: AppDockConstants.SettingsLayout.headerIconSize,
                height: AppDockConstants.SettingsLayout.headerIconSize
            )

            VStack(alignment: .leading, spacing: AppDockConstants.SettingsLayout.headerTextSpacing) {
                Text("Settings")
                    .font(.title2)
                    .bold()
                Text("Configure AppDock preferences.")
                    .foregroundColor(.secondary)
            }
        }
    }
}
