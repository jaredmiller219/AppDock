//
//  AppDockUITests.swift
//  AppDockUITests
//
//  Created by Jared Miller on 12/12/24.
//

import XCTest
import AppDock

/// Basic UI test scaffold for AppDock.
final class AppDockUITests: XCTestCase {

    @MainActor
    private func launchAppForPopoverTests() -> XCUIApplication {
        // Launch with test-only flags to open the popover and seed dock data.
        let app = XCUIApplication()
        app.launchArguments = [
            AppDockConstants.Testing.uiTestMode,
            AppDockConstants.Testing.uiTestOpenPopover,
            AppDockConstants.Testing.uiTestSeedDock,
            AppDockConstants.Testing.uiTestDisableActivation
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
        let app = XCUIApplication()
        app.launch()
        app.activate()

        // Prefer the Settings keyboard shortcut to avoid menu bar hit-testing flakiness.
        app.typeKey(",", modifierFlags: [.command])

        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 2))

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
        let app = XCUIApplication()
        app.launch()
        app.activate()

        app.typeKey(",", modifierFlags: [.command])
        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 2))

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

        let filterButton = app.buttons[AppDockConstants.Accessibility.dockFilterMenu]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 2))

        XCTAssertTrue(app.otherElements[AppDockConstants.Accessibility.dockSlotPrefix + "0"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements[AppDockConstants.Accessibility.dockSlotPrefix + "11"].waitForExistence(timeout: 2))

        XCTAssertTrue(app.buttons[AppDockConstants.Accessibility.menuRowPrefix + "Settings"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons[AppDockConstants.Accessibility.menuRowPrefix + "About"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons[AppDockConstants.Accessibility.menuRowPrefix + "Quit AppDock"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testFilterMenuListsOptions() throws {
        // Confirm the filter/sort menu options are present.
        let app = launchAppForPopoverTests()

        let filterButton = app.buttons[AppDockConstants.Accessibility.dockFilterMenu]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 2))
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
        let app = launchAppForPopoverTests()

        let settingsRow = app.buttons[AppDockConstants.Accessibility.menuRowPrefix + "Settings"]
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 2))
        settingsRow.click()

        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 2))
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
