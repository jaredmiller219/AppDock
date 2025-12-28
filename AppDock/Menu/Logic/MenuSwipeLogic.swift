//
//  MenuSwipeLogic.swift
//  AppDock
//
/*
 MenuSwipeLogic.swift

 Purpose:
  - Encapsulates small pure functions used to determine page ordering and
    whether an interactive swipe/drag should commit to a page change.

 Notes:
  - Keeping this logic pure makes it easy to test without UI dependencies.
*/

import CoreGraphics
import Foundation

/// Pure utility functions around menu page ordering and swipe thresholds.
enum MenuSwipeLogic {
    /// Returns the stable ordering for menu pages used by swipe navigation.
    static func orderedPages() -> [MenuPage] {
        MenuPage.allCases.sorted { $0.orderIndex < $1.orderIndex }
    }

    /// Computes the commit threshold in points for the given popover width.
    /// Uses a minimum threshold and a width-proportional fraction.
    static func commitThreshold(width: CGFloat) -> CGFloat {
        max(AppDockConstants.MenuGestures.swipeThreshold,
            width * AppDockConstants.MenuGestures.swipePageThresholdFraction)
    }

    /// Returns whether the supplied drag deltas should commit to a page
    /// change. Requires horizontal movement to dominate vertical.
    static func shouldCommit(horizontal: CGFloat, vertical: CGFloat, width: CGFloat) -> Bool {
        guard abs(horizontal) > abs(vertical) else { return false }
        return abs(horizontal) >= commitThreshold(width: width)
    }

    /// Returns the next page for a given `direction`, or `nil` if out-of-bounds.
    static func nextPage(from current: MenuPage, direction: SwipeDirection) -> MenuPage? {
        let pages = orderedPages()
        guard let currentIndex = pages.firstIndex(of: current) else { return nil }
        let nextIndex = direction == .left ? currentIndex + 1 : currentIndex - 1
        guard pages.indices.contains(nextIndex) else { return nil }
        return pages[nextIndex]
    }
}
