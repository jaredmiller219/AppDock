//
//  IconView.swift
//  AppDock
//
/*
 IconView.swift

 Purpose:
    - Small, focused view for rendering an `NSImage` app icon with consistent
        sizing and corner radius used throughout dock tiles and lists.

 Overview:
    - Keeps image resizing and accessibility identifier logic in one place so
        callers can pass pre-sized icons and rely on consistent visual styling.
*/

import AppKit
import SwiftUI

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
