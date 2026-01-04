//
//  SettingsUITests.swift
//  AppDockUITests
//

import XCTest

final class SettingsUITests: UITestBase {
    @MainActor
    func testSettingsWindow_flow() throws {
        let (app, settingsWindow) = launchAppAndOpenSettings()

        let applyButton = settingsWindow.buttons["Apply"]
        XCTAssertTrue(applyButton.exists)

        navigateToTab(in: settingsWindow, tabName: "Behavior")

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
        let (_, settingsWindow) = launchAppAndOpenSettings()

        navigateToTab(in: settingsWindow, tabName: "General")
        XCTAssertTrue(settingsWindow.checkBoxes["Launch at login"].waitForExistence(timeout: 2))

        navigateToTab(in: settingsWindow, tabName: "Layout")
        XCTAssertTrue(settingsWindow.staticTexts["Columns"].waitForExistence(timeout: 2))

        navigateToTab(in: settingsWindow, tabName: "Filtering")
        XCTAssertTrue(settingsWindow.staticTexts["Default filter"].waitForExistence(timeout: 2))

        navigateToTab(in: settingsWindow, tabName: "Behavior")
        XCTAssertTrue(settingsWindow.checkBoxes["Show running indicator"].waitForExistence(timeout: 2))

        navigateToTab(in: settingsWindow, tabName: "Shortcuts")
        XCTAssertTrue(settingsWindow.staticTexts["Toggle popover"].waitForExistence(timeout: 2))

        navigateToTab(in: settingsWindow, tabName: "Accessibility")
        XCTAssertTrue(settingsWindow.checkBoxes["Reduce motion"].waitForExistence(timeout: 2))

        navigateToTab(in: settingsWindow, tabName: "Advanced")
        XCTAssertTrue(settingsWindow.checkBoxes["Enable debug logging"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLayoutTabShowsMenuLayoutPicker() throws {
        let (_, settingsWindow) = launchAppAndOpenSettings()

        navigateToTab(in: settingsWindow, tabName: "Layout")
        let layoutPicker = anyElement(in: settingsWindow, id: UITestConstants.Accessibility.settingsMenuLayoutPicker)
        XCTAssertTrue(layoutPicker.waitForExistence(timeout: 2))
    }

    @MainActor
    func testAdvancedTabShowsSettingsLayoutToggle() throws {
        let (_, settingsWindow) = launchAppAndOpenSettings()

        navigateToTab(in: settingsWindow, tabName: "Advanced")
        XCTAssertTrue(settingsWindow.checkBoxes["Use advanced settings layout"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testApplyButtonDisabledUntilChangesMade() throws {
        let (app, settingsWindow) = launchAppAndOpenSettings()

        let applyButton = settingsWindow.buttons["Apply"]
        let actionsButton = anyElement(in: settingsWindow, id: "Settings Actions")
        XCTAssertTrue(actionsButton.waitForExistence(timeout: 2))
        actionsButton.click()
        XCTAssertTrue(app.menuItems["Restore Defaults"].waitForExistence(timeout: 1))
        app.menuItems["Restore Defaults"].click()
        XCTAssertFalse(applyButton.isEnabled)

        navigateToTab(in: settingsWindow, tabName: "Behavior")
        let labelToggle = settingsWindow.checkBoxes["Show app labels"]
        XCTAssertTrue(labelToggle.waitForExistence(timeout: 2))
        labelToggle.click()
        XCTAssertTrue(applyButton.isEnabled)
    }

    @MainActor
    func testSidebarButtonsRespondToFullRowClicks() throws {
        let (_, settingsWindow) = launchAppAndOpenSettings()

        let layoutButton = settingsWindow.buttons["Layout"]
        XCTAssertTrue(layoutButton.waitForExistence(timeout: 2))
        let rightEdge = layoutButton.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
        rightEdge.click()
        XCTAssertTrue(settingsWindow.staticTexts["Columns"].waitForExistence(timeout: 2))
    }
}
