//
//  UITestBase.swift
//  AppDockUITests
//

import XCTest

class UITestBase: XCTestCase {
    enum UITestConstants {
        enum Accessibility {
            static let dockSlotPrefix = "DockSlot-"
            static let dockFilterMenu = "DockFilterMenu"
            static let menuRowPrefix = "MenuRow-"
            static let uiTestWindow = "AppDock UI Test"
            static let iconPrefix = "DockIcon-"
            static let menuPageButtonPrefix = "MenuPage-"
            static let menuPageHeaderPrefix = "MenuPageHeader-"
            static let statusItem = "AppDockStatusItem"
            static let contextMenu = "DockContextMenu"
            static let shortcutRecorderPrefix = "ShortcutRecorder-"
            static let uiTestTrackpadSwipeLeft = "UITestTrackpadSwipeLeft"
            static let uiTestDismissContextMenu = "UITestDismissContextMenu"
            static let uiTestStatusItemProxy = "UITestStatusItemProxy"
            static let uiTestShortcutsWindow = "AppDock Shortcuts Panel"
            static let uiTestShortcutPrefix = "UITestShortcut-"
            static let uiTestActivationRequest = "UITestActivationRequest"
            static let uiTestSwipeModeLeft = "UITestSwipeModeLeft"
            static let uiTestSwipeModeRight = "UITestSwipeModeRight"
            static let settingsMenuLayoutPicker = "SettingsMenuLayoutPicker"
            static let favoritesEmptyState = "FavoritesEmptyState"
            static let shortcutRecorderValuePrefix = "ShortcutRecorderValue-"
        }

        enum ShortcutActions {
            static let togglePopover = "togglePopover"
            static let nextPage = "nextPage"
            static let previousPage = "previousPage"
            static let openDock = "openDock"
            static let openRecents = "openRecents"
            static let openFavorites = "openFavorites"
            static let openActions = "openActions"
        }

        enum TestingArgs {
            static let uiTestMode = "--ui-test-mode"
            static let uiTestOpenPopover = "--ui-test-open-popover"
            static let uiTestSeedDock = "--ui-test-seed-dock"
            static let uiTestDisableActivation = "--ui-test-disable-activation"
            static let uiTestOpenSettings = "--ui-test-open-settings"
            static let uiTestOpenPopovers = "--ui-test-open-popovers"
            static let uiTestMenuSimple = "--ui-test-menu-simple"
            static let uiTestStatusItemProxy = "--ui-test-status-item-proxy"
            static let uiTestShortcutsPanel = "--ui-test-shortcuts-panel"
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func launchAppForPopoverTests() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            UITestConstants.TestingArgs.uiTestMode,
            UITestConstants.TestingArgs.uiTestOpenPopover,
            UITestConstants.TestingArgs.uiTestSeedDock,
            UITestConstants.TestingArgs.uiTestDisableActivation,
        ]
        app.launch()
        app.activate()
        return app
    }

    @MainActor
    func launchAppForSimplePopoverTests() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            UITestConstants.TestingArgs.uiTestMode,
            UITestConstants.TestingArgs.uiTestOpenPopover,
            UITestConstants.TestingArgs.uiTestSeedDock,
            UITestConstants.TestingArgs.uiTestDisableActivation,
            UITestConstants.TestingArgs.uiTestMenuSimple,
        ]
        app.launch()
        app.activate()
        return app
    }

    @MainActor
    func launchAppForSettingsTests() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            UITestConstants.TestingArgs.uiTestMode,
            UITestConstants.TestingArgs.uiTestOpenSettings,
        ]
        app.launch()
        app.activate()
        return app
    }

    @MainActor
    func launchAppForPopoverAndSettingsTests() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            UITestConstants.TestingArgs.uiTestMode,
            UITestConstants.TestingArgs.uiTestOpenPopovers,
            UITestConstants.TestingArgs.uiTestSeedDock,
            UITestConstants.TestingArgs.uiTestDisableActivation,
        ]
        app.launch()
        app.activate()
        return app
    }

    @MainActor
    func launchAppForStatusItemTests() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            UITestConstants.TestingArgs.uiTestMode,
            UITestConstants.TestingArgs.uiTestSeedDock,
            UITestConstants.TestingArgs.uiTestStatusItemProxy,
        ]
        app.launch()
        app.activate()
        return app
    }

    @MainActor
    func launchAppForShortcutTests() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            UITestConstants.TestingArgs.uiTestMode,
            UITestConstants.TestingArgs.uiTestOpenPopover,
            UITestConstants.TestingArgs.uiTestSeedDock,
            UITestConstants.TestingArgs.uiTestDisableActivation,
            UITestConstants.TestingArgs.uiTestShortcutsPanel,
        ]
        app.launch()
        app.activate()
        return app
    }

    func filterButton(in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .menuButton)
            .matching(identifier: UITestConstants.Accessibility.dockFilterMenu)
            .firstMatch
    }

    @MainActor
    func openActionsPage(in popoverWindow: XCUIElement, app: XCUIApplication) {
        popoverWindow.click()
        let actionsPage = popoverWindow.buttons[UITestConstants.Accessibility.menuPageButtonPrefix + "actions"]
        if actionsPage.waitForExistence(timeout: 4) {
            actionsPage.click()
        }

        let settingsRow = popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "Settings"]
        if !settingsRow.waitForExistence(timeout: 1) {
            app.typeKey("4", modifierFlags: .command)
        }
        _ = settingsRow.waitForExistence(timeout: 2)
    }

    @MainActor
    func dragPopover(_ popoverWindow: XCUIElement, fromX: CGFloat, toX: CGFloat, yPosition: CGFloat) {
        popoverWindow.click()
        let start = popoverWindow.coordinate(withNormalizedOffset: CGVector(dx: fromX, dy: yPosition))
        let end = popoverWindow.coordinate(withNormalizedOffset: CGVector(dx: toX, dy: yPosition))
        start.press(forDuration: 0.1, thenDragTo: end)
    }

    @nonobjc
    func anyElement(in popoverWindow: XCUIElement, id: String) -> XCUIElement {
        popoverWindow.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    @nonobjc
    func anyElement(in app: XCUIApplication, id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    @MainActor
    func commandClick(_ element: XCUIElement) {
        XCUIElement.perform(withKeyModifiers: [.command]) {
            element.click()
        }
    }

    func waitForDisappearance(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    func statusItem(in app: XCUIApplication) -> XCUIElement {
        let byIdentifier = anyElement(in: app, id: UITestConstants.Accessibility.statusItem)
        if byIdentifier.exists {
            return byIdentifier
        }
        let statusItemQuery = app.descendants(matching: .statusItem)
        return statusItemQuery.firstMatch
    }
}
