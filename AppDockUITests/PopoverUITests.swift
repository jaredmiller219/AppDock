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
    func testPopoverTrackpadScrollSwipeLeftSwitchesToRecents() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let filterButton = popoverWindow.menuButtons[UITestConstants.Accessibility.dockFilterMenu]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 4))

        let trackpadTrigger = anyElement(in: popoverWindow,
                                         id: UITestConstants.Accessibility.uiTestTrackpadSwipeLeft)
        XCTAssertTrue(trackpadTrigger.waitForExistence(timeout: 2))
        trackpadTrigger.click()

        let recentsHeader = anyElement(in: popoverWindow,
                                       id: UITestConstants.Accessibility.menuPageHeaderPrefix + "recents")
        XCTAssertTrue(recentsHeader.waitForExistence(timeout: 4))
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
    func testPopoverHalfSwipeDragDoesNotChangeTab() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let filterButton = popoverWindow.menuButtons[UITestConstants.Accessibility.dockFilterMenu]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 4))

        dragPopover(popoverWindow, fromX: 0.85, toX: 0.55, y: 0.5)

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

    @MainActor
    func testPopoverCommandClickOpensAndDismissesContextMenu() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let slot0 = popoverWindow.buttons[UITestConstants.Accessibility.dockSlotPrefix + "0"]
        XCTAssertTrue(slot0.waitForExistence(timeout: 4))

        commandClick(slot0)

        let contextMenu = anyElement(in: popoverWindow, id: UITestConstants.Accessibility.contextMenu)
        XCTAssertTrue(contextMenu.waitForExistence(timeout: 2))

        let dismissTrigger = popoverWindow.buttons[UITestConstants.Accessibility.uiTestDismissContextMenu]
        XCTAssertTrue(dismissTrigger.waitForExistence(timeout: 2))
        dismissTrigger.click()
        XCTAssertTrue(waitForDisappearance(contextMenu, timeout: 2))
    }

    @MainActor
    func testPopoverRecentsShowsSeededApps() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        dragPopover(popoverWindow, fromX: 0.85, toX: 0.15, y: 0.5)

        let recentsHeader = anyElement(in: popoverWindow,
                                       id: UITestConstants.Accessibility.menuPageHeaderPrefix + "recents")
        XCTAssertTrue(recentsHeader.waitForExistence(timeout: 4))
        XCTAssertTrue(popoverWindow.buttons["Alpha"].waitForExistence(timeout: 4))
        XCTAssertTrue(popoverWindow.buttons["Bravo"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testPopoverRecentsClickRequestsActivation() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        dragPopover(popoverWindow, fromX: 0.85, toX: 0.15, y: 0.5)

        let recentsHeader = anyElement(in: popoverWindow,
                                       id: UITestConstants.Accessibility.menuPageHeaderPrefix + "recents")
        XCTAssertTrue(recentsHeader.waitForExistence(timeout: 4))

        let alphaButton = popoverWindow.buttons["Alpha"]
        XCTAssertTrue(alphaButton.waitForExistence(timeout: 4))
        alphaButton.click()

        let activationLabel = anyElement(in: popoverWindow,
                                         id: UITestConstants.Accessibility.uiTestActivationRequest)
        XCTAssertTrue(activationLabel.waitForExistence(timeout: 2))
        let activationPredicate = NSPredicate(format: "value == %@", "com.example.alpha")
        expectation(for: activationPredicate, evaluatedWith: activationLabel)
        waitForExpectations(timeout: 2)
    }

    @MainActor
    func testPopoverSwipeModeIndicators() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        let leftMode = anyElement(in: popoverWindow, id: UITestConstants.Accessibility.uiTestSwipeModeLeft)
        let rightMode = anyElement(in: popoverWindow, id: UITestConstants.Accessibility.uiTestSwipeModeRight)
        XCTAssertTrue(leftMode.waitForExistence(timeout: 2))
        XCTAssertTrue(rightMode.waitForExistence(timeout: 2))
        let leftSnapPredicate = NSPredicate(format: "value == %@", "snap")
        expectation(for: leftSnapPredicate, evaluatedWith: leftMode)
        waitForExpectations(timeout: 2)

        dragPopover(popoverWindow, fromX: 0.85, toX: 0.15, y: 0.5)
        let recentsHeader = anyElement(in: popoverWindow,
                                       id: UITestConstants.Accessibility.menuPageHeaderPrefix + "recents")
        XCTAssertTrue(recentsHeader.waitForExistence(timeout: 4))
        let rightSnapPredicate = NSPredicate(format: "value == %@", "snap")
        expectation(for: rightSnapPredicate, evaluatedWith: rightMode)
        let leftInteractivePredicate = NSPredicate(format: "value == %@", "interactive")
        expectation(for: leftInteractivePredicate, evaluatedWith: leftMode)
        waitForExpectations(timeout: 2)
    }

    @MainActor
    func testPopoverFavoritesShowsEmptyState() throws {
        let app = launchAppForPopoverTests()
        let popoverWindow = app.windows[UITestConstants.Accessibility.uiTestWindow]
        XCTAssertTrue(popoverWindow.waitForExistence(timeout: 4))

        dragPopover(popoverWindow, fromX: 0.85, toX: 0.15, y: 0.5)
        let recentsHeader = anyElement(in: popoverWindow,
                                       id: UITestConstants.Accessibility.menuPageHeaderPrefix + "recents")
        XCTAssertTrue(recentsHeader.waitForExistence(timeout: 4))
        dragPopover(popoverWindow, fromX: 0.85, toX: 0.15, y: 0.5)

        let favoritesHeader = anyElement(in: popoverWindow,
                                         id: UITestConstants.Accessibility.menuPageHeaderPrefix + "favorites")
        XCTAssertTrue(favoritesHeader.waitForExistence(timeout: 4))
        XCTAssertTrue(popoverWindow.staticTexts["No Favorites Yet"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testStatusItemClickOpensPopover() throws {
        let app = launchAppForStatusItemTests()

        let statusItem = statusItem(in: app)
        _ = statusItem.waitForExistence(timeout: 4)
        statusItem.click()

        let filterButton = filterButton(in: app)
        if !filterButton.waitForExistence(timeout: 2) {
            let proxyButton = app.buttons[UITestConstants.Accessibility.uiTestStatusItemProxy]
            XCTAssertTrue(proxyButton.waitForExistence(timeout: 4))
            proxyButton.click()
        }
        XCTAssertTrue(filterButton.waitForExistence(timeout: 6))
    }
}
