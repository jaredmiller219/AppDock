//
//  AppDockUITests.swift
//  AppDockUITests
//
//  Created by Jared Miller on 12/12/24.
//

import XCTest

/// Basic UI test scaffold for AppDock.
final class AppDockUITests: XCTestCase {

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
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
