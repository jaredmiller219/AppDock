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
        }

        enum TestingArgs {
            static let uiTestMode = "--ui-test-mode"
            static let uiTestOpenPopover = "--ui-test-open-popover"
            static let uiTestSeedDock = "--ui-test-seed-dock"
            static let uiTestDisableActivation = "--ui-test-disable-activation"
            static let uiTestOpenSettings = "--ui-test-open-settings"
            static let uiTestOpenPopovers = "--ui-test-open-popovers"
            static let uiTestMenuSimple = "--ui-test-menu-simple"
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
            UITestConstants.TestingArgs.uiTestDisableActivation
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
            UITestConstants.TestingArgs.uiTestMenuSimple
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
            UITestConstants.TestingArgs.uiTestOpenSettings
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
            UITestConstants.TestingArgs.uiTestDisableActivation
        ]
        app.launch()
        app.activate()
        return app
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
    func dragPopover(_ popoverWindow: XCUIElement, fromX: CGFloat, toX: CGFloat, y: CGFloat) {
        let start = popoverWindow.coordinate(withNormalizedOffset: CGVector(dx: fromX, dy: y))
        let end = popoverWindow.coordinate(withNormalizedOffset: CGVector(dx: toX, dy: y))
        start.press(forDuration: 0.05, thenDragTo: end)
    }
}
