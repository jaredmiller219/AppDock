//
//  VisualEffectBlur.swift
//  AppDock
//

import AppKit
import SwiftUI

/// Simple NSVisualEffectView wrapper to add a blur behind context menus.
struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
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
