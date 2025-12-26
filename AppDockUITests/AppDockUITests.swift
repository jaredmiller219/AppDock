//
//  AppDockUITests.swift
//  AppDockUITests
//
//  Created by Jared Miller on 12/12/24.
//

import XCTest

/// Basic UI test scaffold for AppDock.
final class AppDockUITests: XCTestCase {
    private enum UITestConstants {
        enum Accessibility {
            static let dockSlotPrefix = "DockSlot-"
            static let dockFilterMenu = "DockFilterMenu"
            static let menuRowPrefix = "MenuRow-"
            static let uiTestWindow = "AppDock UI Test"
            static let iconPrefix = "DockIcon-"
            static let menuPageButtonPrefix = "MenuPage-"
        }

        enum TestingArgs {
            static let uiTestMode = "--ui-test-mode"
            static let uiTestOpenPopover = "--ui-test-open-popover"
            static let uiTestSeedDock = "--ui-test-seed-dock"
            static let uiTestDisableActivation = "--ui-test-disable-activation"
            static let uiTestOpenSettings = "--ui-test-open-settings"
            static let uiTestOpenPopovers = "--ui-test-open-popovers"
        }
    }

    @MainActor
    private func launchAppForPopoverTests() -> XCUIApplication {
        // Launch with test-only flags to open the popover and seed dock data.
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
    private func launchAppForSettingsTests() -> XCUIApplication {
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
    private func launchAppForPopoverAndSettingsTests() -> XCUIApplication {
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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testSettingsWindow_flow() throws {
        // Smoke test: open Settings, toggle a value, and ensure Apply enables.
        let app = launchAppForSettingsTests()

        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))

        let applyButton = settingsWindow.buttons["Apply"]
        XCTAssertTrue(applyButton.exists)

        let behaviorTab = settingsWindow.buttons["Behavior"]
        if behaviorTab.waitForExistence(timeout: 2) {
            behaviorTab.click()
        }

        let labelToggle = settingsWindow.checkBoxes["Show app labels"]
        if labelToggle.waitForExistence(timeout: 2) {
            labelToggle.click()
            XCTAssertTrue(applyButton.isEnabled)
        }

        let actionsButton = settingsWindow.buttons["Settings Actions"]
        if actionsButton.waitForExistence(timeout: 2) {
            actionsButton.click()
            XCTAssertTrue(app.menuItems["Restore Defaults"].waitForExistence(timeout: 1))
            XCTAssertTrue(app.menuItems["Set as Default"].waitForExistence(timeout: 1))
        }
    }

    @MainActor
    func testSettingsTabsContainControls() throws {
        // Verify each settings tab exposes its expected controls.
        let app = launchAppForSettingsTests()
        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))

        settingsWindow.buttons["General"].click()
        XCTAssertTrue(settingsWindow.checkBoxes["Launch at login"].waitForExistence(timeout: 2))

        settingsWindow.buttons["Layout"].click()
        XCTAssertTrue(settingsWindow.staticTexts["Columns"].waitForExistence(timeout: 2))

        settingsWindow.buttons["Filtering"].click()
        XCTAssertTrue(settingsWindow.staticTexts["Default filter"].waitForExistence(timeout: 2))

        settingsWindow.buttons["Behavior"].click()
        XCTAssertTrue(settingsWindow.checkBoxes["Show running indicator"].waitForExistence(timeout: 2))

        settingsWindow.buttons["Accessibility"].click()
        XCTAssertTrue(settingsWindow.checkBoxes["Reduce motion"].waitForExistence(timeout: 2))

        settingsWindow.buttons["Advanced"].click()
        XCTAssertTrue(settingsWindow.checkBoxes["Enable debug logging"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testPopoverShowsDockAndMenuRows() throws {
        // Validate the seeded dock grid and menu rows are visible in the popover.
        let app = launchAppForPopoverTests()

        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let filterButton = popoverWindow.menuButtons[UITestConstants.Accessibility.dockFilterMenu]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 4))

        let slot0 = popoverWindow.buttons[UITestConstants.Accessibility.dockSlotPrefix + "0"]
        if !slot0.waitForExistence(timeout: 4) {
            XCTFail("Missing DockSlot-0. UI tree:\n\(popoverWindow.debugDescription)")
        }
        let slot1 = popoverWindow.buttons[UITestConstants.Accessibility.dockSlotPrefix + "1"]
        if !slot1.waitForExistence(timeout: 4) {
            XCTFail("Missing DockSlot-1. UI tree:\n\(popoverWindow.debugDescription)")
        }

        let actionsPage = popoverWindow.buttons[UITestConstants.Accessibility.menuPageButtonPrefix + "actions"]
        XCTAssertTrue(actionsPage.waitForExistence(timeout: 4))
        actionsPage.click()

        XCTAssertTrue(popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "Settings"].waitForExistence(timeout: 4))
        XCTAssertTrue(popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "About"].waitForExistence(timeout: 4))
        XCTAssertTrue(popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "Quit AppDock"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testFilterMenuListsOptions() throws {
        // Confirm the filter/sort menu options are present.
        let app = launchAppForPopoverTests()

        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let filterButton = popoverWindow.menuButtons[UITestConstants.Accessibility.dockFilterMenu]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 4))
        filterButton.click()

        XCTAssertTrue(app.menuItems["All Apps"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.menuItems["Running Only"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.menuItems["Recently Opened"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.menuItems["Name A-Z"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.menuItems["Name Z-A"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testPopoverSettingsRowOpensSettingsWindow() throws {
        // Integration check: popover Settings row opens the settings window.
        let app = launchAppForPopoverAndSettingsTests()

        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let actionsPage = popoverWindow.buttons[UITestConstants.Accessibility.menuPageButtonPrefix + "actions"]
        XCTAssertTrue(actionsPage.waitForExistence(timeout: 4))
        actionsPage.click()

        let settingsRow = popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "Settings"]
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 4))
        settingsRow.click()

        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
