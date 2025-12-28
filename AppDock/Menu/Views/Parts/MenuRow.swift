//
//  MenuRow.swift
//  AppDock
//

import SwiftUI

/// Single menu row with hover feedback.
struct MenuRow: View {
    let title: String
    let action: () -> Void
    @State private var isHovering = false
    private var accessibilityHintText: String {
        "Activate \(title)"
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, AppDockConstants.MenuRow.paddingHorizontal)
            .padding(.vertical, AppDockConstants.MenuRow.paddingVertical)
            .background(
                RoundedRectangle(cornerRadius: AppDockConstants.MenuRow.cornerRadius)
                    .fill(isHovering ? Color.primary.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: AppDockConstants.MenuRow.cornerRadius))
        .accessibilityIdentifier(AppDockConstants.Accessibility.menuRowPrefix + title)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(accessibilityHintText))
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
