//
//  EmptySlot.swift
//  AppDock
//

import SwiftUI

// MARK: - EmptySlot

/// Placeholder slot shown when there are fewer apps than grid cells.
struct EmptySlot: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Color.clear
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: AppDockConstants.EmptySlot.cornerRadius)
                    .stroke(Color.gray.opacity(AppDockConstants.EmptySlot.strokeOpacity), lineWidth: 1)
            )
            .overlay(
                Text(AppDockConstants.EmptySlot.labelText)
                    .foregroundColor(.gray)
                    .font(.system(size: AppDockConstants.EmptySlot.fontSize))
            )
            .accessibilityIdentifier(AppDockConstants.Accessibility.emptySlot)
    }
}
