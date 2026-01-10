/*
 VisualEffectBlur.swift
 AppDock

 PURPOSE:
 This view wraps NSVisualEffectView to apply macOS vibrancy/blur effects in SwiftUI.
 Used for context menu backgrounds and other surfaces that need depth perception.

 OVERVIEW:
 VisualEffectBlur is an NSViewRepresentable providing a straightforward bridge
 from SwiftUI to AppKit's NSVisualEffectView. It accepts material and blending mode
 to control the visual effect appearance.

 STYLING:
 - Material: Controls blur style (in-window, under window, sidebar, etc.)
 - BlendingMode: Controls how the effect blends with background
 - State: Always set to .active for full effect visibility

 USAGE:
 Used as a background in ContextMenuView to create subtle blur behind action menu.
*/

import AppKit
import SwiftUI

/// NSViewRepresentable wrapper for NSVisualEffectView providing macOS blur effects.
///
/// Applies vibrancy and blur effects using native AppKit visual effects for depth
/// and visual hierarchy in SwiftUI views.
struct VisualEffectBlur: NSViewRepresentable {
    /// Material/style of the blur effect (in-window, under-window, sidebar, etc.)
    let material: NSVisualEffectView.Material

    /// Blending mode controlling how the effect blends with background
    let blendingMode: NSVisualEffectView.BlendingMode

    /// Apply visual configuration to an `NSVisualEffectView`.
    ///
    /// - Parameters:
    ///   - view: The view to configure.
    ///   - material: The visual material to apply.
    ///   - blendingMode: The blending mode for the effect.
    static func configure(
        _ view: NSVisualEffectView,
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode
    ) {
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
    }

    func makeNSView(context _: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        Self.configure(view, material: material, blendingMode: blendingMode)
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context _: Context) {
        // Re-apply configuration when SwiftUI updates the view.
        Self.configure(nsView, material: material, blendingMode: blendingMode)
    }
}
