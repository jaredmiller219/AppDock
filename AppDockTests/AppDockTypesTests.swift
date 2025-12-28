@testable import AppDock
import XCTest
import SwiftUI

final class AppDockTypesTests: XCTestCase {
    func testFilterOptionTitles() {
        XCTAssertEqual(AppFilterOption.all.title, "All Apps")
        XCTAssertEqual(AppFilterOption.runningOnly.title, "Running Only")
    }

    func testSortOptionTitles() {
        XCTAssertEqual(AppSortOption.recent.title, "Recently Opened")
        XCTAssertEqual(AppSortOption.nameAscending.title, "Name A-Z")
        XCTAssertEqual(AppSortOption.nameDescending.title, "Name Z-A")
    }

    func testMenuPageMappings() {
        XCTAssertEqual(MenuPage.dock.title, "Dock")
        XCTAssertEqual(MenuPage.recents.title, "Recents")
        XCTAssertEqual(MenuPage.favorites.title, "Favorites")
        XCTAssertEqual(MenuPage.actions.title, "Menu")

        XCTAssertEqual(MenuPage.dock.systemImage, "square.grid.3x3")
        XCTAssertEqual(MenuPage.recents.systemImage, "clock.arrow.circlepath")

        XCTAssertEqual(MenuPage.dock.orderIndex, 0)
        XCTAssertEqual(MenuPage.recents.orderIndex, 1)
        XCTAssertEqual(MenuPage.favorites.orderIndex, 2)
        XCTAssertEqual(MenuPage.actions.orderIndex, 3)

        // Shortcut key should map to orderIndex + 1 (⌘1 .. ⌘4)
        XCTAssertEqual(MenuPage.dock.shortcutKey, KeyEquivalent("1"))
        XCTAssertEqual(MenuPage.actions.shortcutKey, KeyEquivalent("4"))
    }

    func testMenuLayoutModeTitles() {
        XCTAssertEqual(MenuLayoutMode.simple.title, "Simple")
        XCTAssertEqual(MenuLayoutMode.advanced.title, "Advanced")
    }
}
