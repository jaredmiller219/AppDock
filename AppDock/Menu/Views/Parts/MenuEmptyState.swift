/*
 MenuEmptyState.swift
 AppDock

 PURPOSE:
 This view displays a centered empty state message with icon, title, and description.
 Used to show when a list or section has no content to display.

 OVERVIEW:
 MenuEmptyState combines an SF Symbol icon, heading, and secondary text in a centered layout.
 Proper spacing and colors follow system design guidelines with accessibility support.

 STYLING:
 - Icon: title2 size, secondary foreground color
 - Title: headline font
 - Message: caption font with secondary color
 - Centered within parent container

 ACCESSIBILITY:
 - Icon hidden from accessibility (decorative)
 - Text elements combined into single accessibility label
*/

import SwiftUI

/// Displays a centered empty state with icon, title, and message.
/// 
/// Shows when a list or section has no content, providing clear visual feedback
/// with SF Symbol icon, heading, and description text.
struct MenuEmptyState: View {
    /// Title text for the empty state (e.g., "No Recent Apps")
    let title: String
    
    /// Supporting message text describing why list is empty
    let message: String
    
    /// SF Symbol name to display as visual indicator
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
