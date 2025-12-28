//
//  MenuPageBar.swift
//  AppDock
//
/*
 MenuPageBar.swift

 Purpose:
    - Renders the bottom page/tab bar for the popover when using the
        `advanced` menu layout. Shows a button for each `MenuPage` and
        provides keyboard shortcuts and accessibility identifiers.

 Notes:
    - Visual styling uses values from `AppDockConstants.MenuPageBar` so
        the layout remains consistent with the rest of the popover UI.
*/

import SwiftUI

/// Small tab bar that displays one button per `MenuPage`.
struct MenuPageBar: View {
    let selectedPage: MenuPage
    let onSelect: (MenuPage) -> Void

    var body: some View {
        HStack(spacing: AppDockConstants.MenuPageBar.spacing) {
            ForEach(MenuPage.allCases) { page in
                Button {
                    onSelect(page)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppDockConstants.MenuPageBar.cornerRadius)
                            .fill(selectedPage == page ? Color.accentColor.opacity(0.18) : Color.clear)

                        VStack(spacing: AppDockConstants.MenuPageBar.labelSpacing) {
                            Image(systemName: page.systemImage)
                                .font(.system(size: AppDockConstants.MenuPageBar.iconFontSize, weight: .semibold))
                            Text(page.title)
                                .font(.caption2)
                        }
                        .foregroundColor(selectedPage == page ? .accentColor : .primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppDockConstants.MenuPageBar.paddingVertical)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .keyboardShortcut(page.shortcutKey, modifiers: .command)
                .accessibilityIdentifier(AppDockConstants.Accessibility.menuPageButtonPrefix + page.rawValue)
                .accessibilityLabel(Text(page.title))
                .accessibilityHint(Text("Switch to \(page.title) page"))
                .accessibilityAddTraits(selectedPage == page ? .isSelected : [])
            }
        }
        .padding(.top, AppDockConstants.MenuPageBar.topPadding)
    }
}
