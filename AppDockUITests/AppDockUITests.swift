//
//  AppDockUITests.swift
//  AppDockUITests
//
//  Created by Jared Miller on 12/12/24.
//

import XCTest

/// Basic UI test scaffold for AppDock.
final class AppDockUITests: XCTestCase {

    @MainActor
    private func launchAppForPopoverTests() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-test-mode",
            "--ui-test-open-popover",
            "--ui-test-seed-dock",
            "--ui-test-disable-activation"
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
        let app = XCUIApplication()
        app.launch()
        app.activate()

        // Prefer the Settings keyboard shortcut to avoid menu bar hit-testing flakiness.
        app.typeKey(",", modifierFlags: [.command])

        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 2))

        let applyButton = settingsWindow.buttons["Apply"]
        XCTAssertTrue(applyButton.exists)

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
    func testPopoverShowsDockAndMenuRows() throws {
        let app = launchAppForPopoverTests()

        let filterButton = app.buttons["DockFilterMenu"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 2))

        XCTAssertTrue(app.otherElements["DockSlot-0"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements["DockSlot-11"].waitForExistence(timeout: 2))

        XCTAssertTrue(app.buttons["MenuRow-Settings"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["MenuRow-About"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["MenuRow-Quit AppDock"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testFilterMenuListsOptions() throws {
        let app = launchAppForPopoverTests()

        let filterButton = app.buttons["DockFilterMenu"]
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
        let app = launchAppForPopoverTests()

        let settingsRow = app.buttons["MenuRow-Settings"]
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
