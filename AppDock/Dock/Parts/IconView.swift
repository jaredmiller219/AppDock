//
//  IconView.swift
//  AppDock
//

import SwiftUI
import AppKit

// MARK: - IconView

/// Visual icon for an app with consistent sizing.
struct IconView: View {
    let appName: String
    let appIcon: NSImage
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Image(nsImage: appIcon)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .cornerRadius(AppDockConstants.IconView.cornerRadius)
            .accessibilityIdentifier(AppDockConstants.Accessibility.iconPrefix + appName)
    }
}
