//
//  ShortcutsTabUITests.swift
//  AppDockUITests
//
//  UI tests for keyboard shortcuts tab interactions.
//  Tests focus on user interactions (clear button behavior) and hover states.
//  Live preview display timing is verified through comprehensive unit tests in ShortcutRecorderDisplayTests.
//

import XCTest

final class ShortcutsTabUITests: UITestBase {

    // MARK: - Functional Tests for Clear Button Behavior

    /// Test that the clear button appears on hover when a shortcut is set.
    @MainActor
    func testClearButton_appearsOnHover_whenShortcutIsSet() throws {
        let (app, settingsWindow) = launchAppAndOpenSettings()

        navigateToTab(in: settingsWindow, tabName: "Shortcuts")
        let toggleRecorder = getShortcutRecorder(in: settingsWindow, for: "Toggle popover")
        let cancelButton = getShortcutCancelButton(in: settingsWindow, for: "Toggle popover")
        XCTAssertTrue(toggleRecorder.waitForExistence(timeout: 2))

        // Record a shortcut
        toggleRecorder.click()
        recordShortcut(app, key: "k", modifiers: [.command, .option])

        // Move focus away from recorder field
        settingsWindow.click()

        // Button should not be visible when not hovering
        XCTAssertFalse(cancelButton.exists, "Clear button should not appear when not hovering")

        // Hover over the recorder field - button should appear
        toggleRecorder.hover()
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: 1),
            "Clear button should appear when hovering over field with shortcut"
        )
    }

    /// Test that the clear button does not appear when no shortcut is set.
    @MainActor
    func testClearButton_doesNotAppear_whenNoShortcutSet() throws {
        let (_, settingsWindow) = launchAppAndOpenSettings()

        navigateToTab(in: settingsWindow, tabName: "Shortcuts")
        let toggleRecorder = getShortcutRecorder(in: settingsWindow, for: "Toggle popover")
        let cancelButton = getShortcutCancelButton(in: settingsWindow, for: "Toggle popover")
        XCTAssertTrue(toggleRecorder.waitForExistence(timeout: 2))

        // Hover over empty recorder field
        toggleRecorder.hover()

        // Button should still not appear
        XCTAssertFalse(
            cancelButton.exists,
            "Clear button should not appear when field is empty"
        )
    }

    /// Test that clicking the clear button clears the shortcut.
    @MainActor
    func testClearButton_clearsShortcutOnClick() throws {
        let (app, settingsWindow) = launchAppAndOpenSettings()

        navigateToTab(in: settingsWindow, tabName: "Shortcuts")
        let toggleRecorder = getShortcutRecorder(in: settingsWindow, for: "Toggle popover")
        let cancelButton = getShortcutCancelButton(in: settingsWindow, for: "Toggle popover")
        let toggleRecorderValue = getShortcutValueField(in: settingsWindow, for: "Toggle popover")
        XCTAssertTrue(toggleRecorder.waitForExistence(timeout: 2))

        // Record a shortcut
        toggleRecorder.click()
        recordShortcut(app, key: "k", modifiers: [.command, .option])

        // Hover and click clear button
        toggleRecorder.hover()
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 1))
        cancelButton.click()

        // Field should now show "Record Shortcut"
        XCTAssertTrue(
            waitForDisplayedTextContaining(
                toggleRecorderValue,
                substring: "Record",
                timeout: 2
            ),
            "Field should show 'Record Shortcut' after clearing"
        )
    }

}

