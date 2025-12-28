//
//  MenuRow.swift
//  AppDock
//

import SwiftUI

/*
 MenuRow.swift
 AppDock

 PURPOSE:
 This view provides a single clickable menu row with hover feedback and accessibility support.
 Used in the action menu to display Settings, About, and Quit options.

 OVERVIEW:
 MenuRow is a button that displays a title, supports hover highlighting, and provides
 consistent styling for menu actions. It includes accessibility identifiers and hints.

 STYLING:
 - Text uses primary foreground color
 - Hover state fills background with subtle primary color
 - Rounded corners and consistent padding
 - Frame stretches to full width

 ACCESSIBILITY:
 - Accessibility identifier with row title
 - Label with action title
 - Hint text describing the action
*/

/// Single menu row with hover feedback.
struct MenuRow: View {
    /// Title text displayed in the menu row
    let title: String
    
    /// Callback triggered when row is clicked
    let action: () -> Void
    
    /// Local state tracking whether mouse is hovering over row
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
