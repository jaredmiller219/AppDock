/*
 MenuPageHeader.swift
 AppDock

 PURPOSE:
 This view displays the title and icon for the current menu page in a styled header.
 Used in advanced menu layout to show which page is currently active.

 OVERVIEW:
 MenuPageHeader renders the page name and SF Symbol icon in a rounded background container.
 It provides visual context for the displayed page content (recents, favorites, actions).

 STYLING:
 - Uses page title and system image from MenuPage enum
 - Rounded rectangle background with subtle fill color
 - Caption font size
 - Consistent horizontal alignment and padding

 ACCESSIBILITY:
 - Accessibility identifier with page ID suffix
 - Accessibility label with page title
 - Hint text identifying it as current page
*/

import SwiftUI

/// Displays the title and icon for the current menu page in a styled header.
/// 
/// Shows visual context for the active menu page (e.g., "Recents" or "Favorites")
/// in a rounded background container.
struct MenuPageHeader: View {
    /// The menu page whose title and icon should be displayed
    let page: MenuPage

    var body: some View {
        HStack {
            Label(page.title, systemImage: page.systemImage)
                .font(.caption)
            Spacer()
        }
        .padding(.horizontal, AppDockConstants.MenuHeader.paddingHorizontal)
        .padding(.vertical, AppDockConstants.MenuHeader.paddingVertical)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppDockConstants.MenuHeader.cornerRadius)
                .fill(Color.primary.opacity(0.08))
        )
        .accessibilityIdentifier(AppDockConstants.Accessibility.menuPageHeaderPrefix + page.rawValue)
        .accessibilityLabel(Text(page.title))
        .accessibilityHint(Text("Current menu page"))
    }
}
