//
//  ShortcutHotkeyUITests.swift
//  AppDockUITests
//

import XCTest

final class ShortcutHotkeyUITests: UITestBase {
    @MainActor
    func testShortcutTriggersSwitchPages() throws {
        let app = launchAppForShortcutTests()

        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let shortcutsWindow = app.windows[UITestConstants.Accessibility.uiTestShortcutsWindow]
        XCTAssertTrue(shortcutsWindow.waitForExistence(timeout: 4))

        let openRecents = shortcutsWindow.buttons[
            UITestConstants.Accessibility.uiTestShortcutPrefix + UITestConstants.ShortcutActions.openRecents
        ]
        XCTAssertTrue(openRecents.waitForExistence(timeout: 2))
        openRecents.click()
        let recentsHeader = anyElement(
            in: popoverWindow,
            id: UITestConstants.Accessibility.menuPageHeaderPrefix + "recents"
        )
        XCTAssertTrue(recentsHeader.waitForExistence(timeout: 2))

        let openFavorites = shortcutsWindow.buttons[
            UITestConstants.Accessibility.uiTestShortcutPrefix + UITestConstants.ShortcutActions.openFavorites
        ]
        XCTAssertTrue(openFavorites.waitForExistence(timeout: 2))
        openFavorites.click()
        let favoritesHeader = anyElement(
            in: popoverWindow,
            id: UITestConstants.Accessibility.menuPageHeaderPrefix + "favorites"
        )
        XCTAssertTrue(favoritesHeader.waitForExistence(timeout: 2))

        let nextPage = shortcutsWindow.buttons[
            UITestConstants.Accessibility.uiTestShortcutPrefix + UITestConstants.ShortcutActions.nextPage
        ]
        XCTAssertTrue(nextPage.waitForExistence(timeout: 2))
        nextPage.click()
        let actionsHeader = anyElement(
            in: popoverWindow,
            id: UITestConstants.Accessibility.menuPageHeaderPrefix + "actions"
        )
        XCTAssertTrue(actionsHeader.waitForExistence(timeout: 2))
    }
}
