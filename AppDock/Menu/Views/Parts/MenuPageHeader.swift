//
//  MenuPageHeader.swift
//  AppDock
//

import SwiftUI

struct MenuPageHeader: View {
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
