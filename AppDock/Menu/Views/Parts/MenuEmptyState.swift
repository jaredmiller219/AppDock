//
//  MenuEmptyState.swift
//  AppDock
//

import SwiftUI

struct MenuEmptyState: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AppDockConstants.MenuEmptyState.spacing) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppDockConstants.MenuEmptyState.paddingVertical)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title). \(message)"))
    }
}
