//
//  MenuPageBar.swift
//  AppDock
//

import SwiftUI

struct MenuPageBar: View {
    let selectedPage: MenuPage
    let onSelect: (MenuPage) -> Void

    var body: some View {
        HStack(spacing: AppDockConstants.MenuPageBar.spacing) {
            ForEach(MenuPage.allCases) { page in
                Button {
                    onSelect(page)
                } label: {
                    VStack(spacing: AppDockConstants.MenuPageBar.labelSpacing) {
                        Image(systemName: page.systemImage)
                            .font(.system(size: AppDockConstants.MenuPageBar.iconFontSize, weight: .semibold))
                        Text(page.title)
                            .font(.caption2)
                    }
                    .foregroundColor(selectedPage == page ? .accentColor : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppDockConstants.MenuPageBar.paddingVertical)
                    .background(
                        RoundedRectangle(cornerRadius: AppDockConstants.MenuPageBar.cornerRadius)
                            .fill(selectedPage == page ? Color.accentColor.opacity(0.18) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(page.shortcutKey, modifiers: .command)
                .accessibilityIdentifier(AppDockConstants.Accessibility.menuPageButtonPrefix + page.rawValue)
            }
        }
        .padding(.top, AppDockConstants.MenuPageBar.topPadding)
    }
}
