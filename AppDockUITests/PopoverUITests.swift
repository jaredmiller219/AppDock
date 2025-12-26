//
//  PopoverUITests.swift
//  AppDockUITests
//

import XCTest

final class PopoverUITests: UITestBase {
    @MainActor
    func testPopoverShowsDockAndMenuRows() throws {
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

        openActionsPage(in: popoverWindow, app: app)

        XCTAssertTrue(popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "Settings"].waitForExistence(timeout: 4))
        XCTAssertTrue(popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "About"].waitForExistence(timeout: 4))
        XCTAssertTrue(popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "Quit AppDock"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testFilterMenuListsOptions() throws {
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
        let app = launchAppForPopoverTests()

        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        openActionsPage(in: popoverWindow, app: app)

        let settingsRow = popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "Settings"]
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 4))
        settingsRow.click()

        let settingsWindow = app.windows["AppDock Settings"]
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 4))
    }

    @MainActor
    func testPopoverSimpleLayoutShowsActionsWithoutTabs() throws {
        let app = launchAppForSimplePopoverTests()

        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let actionsPage = popoverWindow.buttons[UITestConstants.Accessibility.menuPageButtonPrefix + "actions"]
        XCTAssertFalse(actionsPage.exists)

        XCTAssertTrue(popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "Settings"].waitForExistence(timeout: 4))
        XCTAssertTrue(popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "About"].waitForExistence(timeout: 4))
        XCTAssertTrue(popoverWindow.buttons[UITestConstants.Accessibility.menuRowPrefix + "Quit AppDock"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testPopoverSwipeDragLeftSwitchesToRecents() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let filterButton = popoverWindow.menuButtons[UITestConstants.Accessibility.dockFilterMenu]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 4))

        dragPopover(popoverWindow, fromX: 0.85, toX: 0.15, y: 0.5)

        let recentsHeader = anyElement(in: popoverWindow,
                                       id: UITestConstants.Accessibility.menuPageHeaderPrefix + "recents")
        XCTAssertTrue(recentsHeader.waitForExistence(timeout: 2))
    }

    @MainActor
    func testPopoverSmallSwipeDragDoesNotChangeTab() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let filterButton = popoverWindow.menuButtons[UITestConstants.Accessibility.dockFilterMenu]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 4))

        dragPopover(popoverWindow, fromX: 0.6, toX: 0.5, y: 0.5)

        XCTAssertTrue(filterButton.waitForExistence(timeout: 2))
        let recentsHeader = anyElement(in: popoverWindow,
                                       id: UITestConstants.Accessibility.menuPageHeaderPrefix + "recents")
        XCTAssertFalse(recentsHeader.exists)
    }

    @MainActor
    func testPopoverSwipeDragRightReturnsToDock() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        dragPopover(popoverWindow, fromX: 0.85, toX: 0.15, y: 0.5)
        let recentsHeader = anyElement(in: popoverWindow,
                                       id: UITestConstants.Accessibility.menuPageHeaderPrefix + "recents")
        XCTAssertTrue(recentsHeader.waitForExistence(timeout: 2))

        dragPopover(popoverWindow, fromX: 0.15, toX: 0.85, y: 0.5)
        let filterButton = popoverWindow.menuButtons[UITestConstants.Accessibility.dockFilterMenu]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 2))
    }
}
