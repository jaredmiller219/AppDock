//
//  SettingsUITests.swift
//  AppDockUITests
//

import XCTest

final class SettingsUITests: UITestBase {
    @MainActor
    func testSettingsWindow_flow() throws {
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

        settingsWindow.buttons["Shortcuts"].click()
        XCTAssertTrue(settingsWindow.staticTexts["Toggle popover"].waitForExistence(timeout: 2))

        settingsWindow.buttons["Accessibility"].click()
        XCTAssertTrue(settingsWindow.checkBoxes["Reduce motion"].waitForExistence(timeout: 2))

        settingsWindow.buttons["Advanced"].click()
        XCTAssertTrue(settingsWindow.checkBoxes["Enable debug logging"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testShortcutsTabShowsRecorderFields() throws {
        let app = launchAppForSettingsTests()
        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))

        settingsWindow.buttons["Shortcuts"].click()
        let toggleRecorder = anyElement(
            in: settingsWindow,
            id: UITestConstants.Accessibility.shortcutRecorderPrefix + "Toggle popover"
        )
        XCTAssertTrue(toggleRecorder.waitForExistence(timeout: 2))
    }

    @MainActor
    func testShortcutRecorderRecordsAndClears() throws {
        let app = launchAppForSettingsTests()
        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))

        settingsWindow.buttons["Shortcuts"].click()
        let toggleRecorder = anyElement(
            in: settingsWindow,
            id: UITestConstants.Accessibility.shortcutRecorderPrefix + "Toggle popover"
        )
        XCTAssertTrue(toggleRecorder.waitForExistence(timeout: 2))
        let toggleRecorderValue = anyElement(
            in: settingsWindow,
            id: UITestConstants.Accessibility.shortcutRecorderValuePrefix + "Toggle popover"
        )
        XCTAssertTrue(toggleRecorderValue.waitForExistence(timeout: 2))

        toggleRecorder.click()
        app.typeKey("k", modifierFlags: [.command, .option])
        settingsWindow.click()
        XCTAssertTrue(waitForDisplayedTextContaining(toggleRecorderValue, substring: "K", timeout: 2))
        XCTAssertTrue(waitForDisplayedTextContaining(toggleRecorderValue, substring: "⌘", timeout: 2))

        toggleRecorder.click()
        app.typeKey(XCUIKeyboardKey.delete.rawValue, modifierFlags: [])
        settingsWindow.click()
        XCTAssertTrue(waitForDisplayedTextContaining(toggleRecorderValue, substring: "Record", timeout: 2))
    }

    @MainActor
    func testShortcutRecorderCancelExitsEditMode() throws {
        let app = launchAppForSettingsTests()
        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))

        settingsWindow.buttons["Shortcuts"].click()
        let toggleRecorder = anyElement(
            in: settingsWindow,
            id: UITestConstants.Accessibility.shortcutRecorderPrefix + "Toggle popover"
        )
        let toggleRecorderValue = anyElement(
            in: settingsWindow,
            id: UITestConstants.Accessibility.shortcutRecorderValuePrefix + "Toggle popover"
        )
        XCTAssertTrue(toggleRecorder.waitForExistence(timeout: 2))
        XCTAssertTrue(toggleRecorderValue.waitForExistence(timeout: 2))

        toggleRecorder.click()
        let cancelButton = settingsWindow.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        app.typeKey(XCUIKeyboardKey.escape.rawValue, modifierFlags: [])
        settingsWindow.click()
        XCTAssertTrue(waitForDisappearance(cancelButton, timeout: 2))
        XCTAssertTrue(waitForDisplayedTextContaining(toggleRecorderValue, substring: "Record", timeout: 2))

        toggleRecorder.click()
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        cancelButton.click()
        XCTAssertTrue(waitForDisappearance(cancelButton, timeout: 2))
        XCTAssertTrue(waitForDisplayedTextContaining(toggleRecorderValue, substring: "Record", timeout: 2))
    }

    private func waitForDisplayedTextContaining(
        _ element: XCUIElement,
        substring: String,
        timeout: TimeInterval
    ) -> Bool {
        let predicate = NSPredicate(
            format: "value CONTAINS %@ OR label CONTAINS %@ OR title CONTAINS %@",
            substring,
            substring,
            substring
        )
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    @MainActor
    func testLayoutTabShowsMenuLayoutPicker() throws {
        let app = launchAppForSettingsTests()
        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))

        settingsWindow.buttons["Layout"].click()
        let layoutPicker = anyElement(in: settingsWindow, id: UITestConstants.Accessibility.settingsMenuLayoutPicker)
        XCTAssertTrue(layoutPicker.waitForExistence(timeout: 2))
    }

    @MainActor
    func testAdvancedTabShowsSettingsLayoutToggle() throws {
        let app = launchAppForSettingsTests()
        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))

        settingsWindow.buttons["Advanced"].click()
        XCTAssertTrue(settingsWindow.checkBoxes["Use advanced settings layout"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testApplyButtonDisabledUntilChangesMade() throws {
        let app = launchAppForSettingsTests()
        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))

        let applyButton = settingsWindow.buttons["Apply"]
        let actionsButton = anyElement(in: settingsWindow, id: "Settings Actions")
        XCTAssertTrue(actionsButton.waitForExistence(timeout: 2))
        actionsButton.click()
        XCTAssertTrue(app.menuItems["Restore Defaults"].waitForExistence(timeout: 1))
        app.menuItems["Restore Defaults"].click()
        XCTAssertFalse(applyButton.isEnabled)

        settingsWindow.buttons["Behavior"].click()
        let labelToggle = settingsWindow.checkBoxes["Show app labels"]
        XCTAssertTrue(labelToggle.waitForExistence(timeout: 2))
        labelToggle.click()
        XCTAssertTrue(applyButton.isEnabled)
    }

    @MainActor
    func testSidebarButtonsRespondToFullRowClicks() throws {
        let app = launchAppForSettingsTests()
        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))

        let layoutButton = settingsWindow.buttons["Layout"]
        XCTAssertTrue(layoutButton.waitForExistence(timeout: 2))
        let rightEdge = layoutButton.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
        rightEdge.click()
        XCTAssertTrue(settingsWindow.staticTexts["Columns"].waitForExistence(timeout: 2))
    }
}
