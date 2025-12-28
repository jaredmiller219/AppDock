//
//  EmptySlot.swift
//  AppDock
//
/*
 EmptySlot.swift

 Purpose:
  - Render an unobtrusive placeholder in dock grid cells that do not have
    an associated app entry. The placeholder provides a subtle border and
    a small label so the grid's layout remains visually consistent.
*/

import SwiftUI

// MARK: - EmptySlot

/// Placeholder slot shown when there are fewer apps than grid cells.
///
/// - Parameters:
///   - width: Target width for the placeholder so grid alignment matches icons.
///   - height: Target height for the placeholder so grid alignment matches icons.
struct EmptySlot: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Color.clear
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: AppDockConstants.EmptySlot.cornerRadius)
                    .stroke(
                        Color.gray.opacity(AppDockConstants.EmptySlot.strokeOpacity),
                        lineWidth: AppDockConstants.EmptySlot.strokeLineWidth
                    )
            )
            .overlay(
                Text(AppDockConstants.EmptySlot.labelText)
                    .foregroundColor(.gray)
                    .font(.system(size: AppDockConstants.EmptySlot.fontSize))
            )
            .accessibilityIdentifier(AppDockConstants.Accessibility.emptySlot)
    }
}
