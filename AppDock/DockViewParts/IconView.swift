//
//  IconView.swift
//  AppDock
//

import SwiftUI
import AppKit

// MARK: - IconView

enum IconViewConstants {
    static let cornerRadius: CGFloat = 8
    static let accessibilityIdPrefix = "DockIcon-"
}

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
            .cornerRadius(IconViewConstants.cornerRadius)
            .accessibilityIdentifier(IconViewConstants.accessibilityIdPrefix + appName)
    }
}
