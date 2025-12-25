//
//  EmptySlot.swift
//  AppDock
//

import SwiftUI

// MARK: - EmptySlot

enum EmptySlotConstants {
    static let labelText = "Empty"
    static let cornerRadius: CGFloat = 5
    static let strokeOpacity: Double = 0.4
    static let fontSize: CGFloat = 8
    static let accessibilityId = "DockEmptySlot"
}

/// Placeholder slot shown when there are fewer apps than grid cells.
struct EmptySlot: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Color.clear
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: EmptySlotConstants.cornerRadius)
                    .stroke(Color.gray.opacity(EmptySlotConstants.strokeOpacity), lineWidth: 1)
            )
            .overlay(
                Text(EmptySlotConstants.labelText)
                    .foregroundColor(.gray)
                    .font(.system(size: EmptySlotConstants.fontSize))
            )
            .accessibilityIdentifier(EmptySlotConstants.accessibilityId)
    }
}
