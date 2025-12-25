//
//  VisualEffectBlur.swift
//  AppDock
//

import SwiftUI
import AppKit

/// Simple NSVisualEffectView wrapper to add a blur behind context menus.
struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    static func configure(
        _ view: NSVisualEffectView,
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode
    ) {
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        Self.configure(view, material: material, blendingMode: blendingMode)
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        Self.configure(nsView, material: material, blendingMode: blendingMode)
    }
}
