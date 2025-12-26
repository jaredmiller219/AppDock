//
//  MenuSwipeLogic.swift
//  AppDock
//

import Foundation
import CoreGraphics

struct MenuSwipeLogic {
    static func orderedPages() -> [MenuPage] {
        MenuPage.allCases.sorted { $0.orderIndex < $1.orderIndex }
    }

    static func commitThreshold(width: CGFloat) -> CGFloat {
        max(AppDockConstants.MenuGestures.swipeThreshold,
            width * AppDockConstants.MenuGestures.swipePageThresholdFraction)
    }

    static func shouldCommit(horizontal: CGFloat, vertical: CGFloat, width: CGFloat) -> Bool {
        guard abs(horizontal) > abs(vertical) else { return false }
        return abs(horizontal) >= commitThreshold(width: width)
    }

    static func nextPage(from current: MenuPage, direction: SwipeDirection) -> MenuPage? {
        let pages = orderedPages()
        guard let currentIndex = pages.firstIndex(of: current) else { return nil }
        let nextIndex = direction == .left ? currentIndex + 1 : currentIndex - 1
        guard pages.indices.contains(nextIndex) else { return nil }
        return pages[nextIndex]
    }
}
