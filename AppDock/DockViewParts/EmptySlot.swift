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
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .overlay(
                Text("Empty")
                    .foregroundColor(.gray)
                    .font(.system(size: 8))
            )
    }
}
