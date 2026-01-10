@testable import AppDock
import SwiftUI
import XCTest

/// Tests for the popover host wiring and action closures.
final class MenuControllerTests: XCTestCase {
    // Verify the hosting controller is created with the expected size and root view
    func testMakePopoverController_returnsHostingControllerWithSize() {
        let controller = MenuController()
        let appState = AppDock.AppState()
        let menuState = MenuState()

        let popVC = controller.makePopoverController(
            appState: appState,
            menuState: menuState,
            settingsAction: {},
            aboutAction: {},
            shortcutsAction: {},
            helpAction: {},
            releaseNotesAction: {},
            appGroupsAction: {},
            quitAction: {}
        )

        guard let hosting = popVC as? NSHostingController<PopoverContentView> else {
            XCTFail("Popover controller should be an NSHostingController<PopoverContentView>")
            return
        }

        XCTAssertEqual(hosting.view.frame.size.width, PopoverSizing.defaultWidth, accuracy: 0.1)
        XCTAssertEqual(hosting.view.frame.size.height, PopoverSizing.height, accuracy: 0.1)
        XCTAssertTrue(hosting.rootView.appState === appState)
    }

    func testMakePopoverController_widthExpandsWithExtraColumns() {
        let controller = MenuController()
        let appState = AppDock.AppState()
        let menuState = MenuState()
        appState.gridColumns = SettingsDefaults.gridColumnsDefault + 2

        let popVC = controller.makePopoverController(
            appState: appState,
            menuState: menuState,
            settingsAction: {},
            aboutAction: {},
            shortcutsAction: {},
            helpAction: {},
            releaseNotesAction: {},
            appGroupsAction: {},
            quitAction: {}
        )

        guard let hosting = popVC as? NSHostingController<PopoverContentView> else {
            XCTFail("Popover controller should be an NSHostingController<PopoverContentView>")
            return
        }

        let expectedWidth = PopoverSizing.width(for: appState)
        XCTAssertEqual(hosting.view.frame.size.width, expectedWidth, accuracy: 0.1)
    }

    func testMakePopoverController_widthStaysDefaultWhenColumnsBelowDefault() {
        let controller = MenuController()
        let appState = AppDock.AppState()
        let menuState = MenuState()
        appState.gridColumns = max(0, SettingsDefaults.gridColumnsDefault - 2)

        let popVC = controller.makePopoverController(
            appState: appState,
            menuState: menuState,
            settingsAction: {},
            aboutAction: {},
            shortcutsAction: {},
            helpAction: {},
            releaseNotesAction: {},
            appGroupsAction: {},
            quitAction: {}
        )

        guard let hosting = popVC as? NSHostingController<PopoverContentView> else {
            XCTFail("Popover controller should be an NSHostingController<PopoverContentView>")
            return
        }

        XCTAssertEqual(hosting.view.frame.size.width, PopoverSizing.defaultWidth, accuracy: 0.1)
    }

    func testMakePopoverController_heightAlwaysUsesPopoverSizingHeight() {
        let controller = MenuController()
        let appState = AppDock.AppState()
        let menuState = MenuState()
        appState.gridColumns = SettingsDefaults.gridColumnsDefault + 3
        appState.iconSize = SettingsDefaults.iconSizeDefault + 12

        let popVC = controller.makePopoverController(
            appState: appState,
            menuState: menuState,
            settingsAction: {},
            aboutAction: {},
            shortcutsAction: {},
            helpAction: {},
            releaseNotesAction: {},
            appGroupsAction: {},
            quitAction: {}
        )

        guard let hosting = popVC as? NSHostingController<PopoverContentView> else {
            XCTFail("Popover controller should be an NSHostingController<PopoverContentView>")
            return
        }

        XCTAssertEqual(hosting.view.frame.size.height, PopoverSizing.height, accuracy: 0.1)
    }

    func testMakePopoverController_widthAccountsForIconSizeChanges() {
        let controller = MenuController()
        let appState = AppDock.AppState()
        let menuState = MenuState()
        appState.gridColumns = SettingsDefaults.gridColumnsDefault + 1
        appState.iconSize = SettingsDefaults.iconSizeDefault + 10

        let popVC = controller.makePopoverController(
            appState: appState,
            menuState: menuState,
            settingsAction: {},
            aboutAction: {},
            shortcutsAction: {},
            helpAction: {},
            releaseNotesAction: {},
            appGroupsAction: {},
            quitAction: {}
        )

        guard let hosting = popVC as? NSHostingController<PopoverContentView> else {
            XCTFail("Popover controller should be an NSHostingController<PopoverContentView>")
            return
        }

        let expectedWidth = PopoverSizing.width(for: appState)
        XCTAssertEqual(hosting.view.frame.size.width, expectedWidth, accuracy: 0.1)
    }

    // Verify button actions are wired through the view
    func testMakePopoverController_wiresActions() {
        let controller = MenuController()
        let appState = AppDock.AppState()
        let menuState = MenuState()
        var settingsCalled = false
        var aboutCalled = false
        var shortcutsCalled = false
        var helpCalled = false
        var releaseNotesCalled = false
        var appGroupsCalled = false
        var quitCalled = false

        let popVC = controller.makePopoverController(
            appState: appState,
            menuState: menuState,
            settingsAction: { settingsCalled = true },
            aboutAction: { aboutCalled = true },
            shortcutsAction: { shortcutsCalled = true },
            helpAction: { helpCalled = true },
            releaseNotesAction: { releaseNotesCalled = true },
            appGroupsAction: { appGroupsCalled = true },
            quitAction: { quitCalled = true }
        )

        guard let hosting = popVC as? NSHostingController<PopoverContentView> else {
            XCTFail("Popover controller should be an NSHostingController<PopoverContentView>")
            return
        }

        // Trigger actions directly through the view's closures
        hosting.rootView.settingsAction()
        hosting.rootView.aboutAction()
        hosting.rootView.shortcutsAction()
        hosting.rootView.helpAction()
        hosting.rootView.releaseNotesAction()
        hosting.rootView.appGroupsAction()
        hosting.rootView.quitAction()

        XCTAssertTrue(settingsCalled, "Settings action should be wired.")
        XCTAssertTrue(aboutCalled, "About action should be wired.")
        XCTAssertTrue(shortcutsCalled, "Shortcuts action should be wired.")
        XCTAssertTrue(helpCalled, "Help action should be wired.")
        XCTAssertTrue(releaseNotesCalled, "Release Notes action should be wired.")
        XCTAssertTrue(appGroupsCalled, "App Groups action should be wired.")
        XCTAssertTrue(quitCalled, "Quit action should be wired.")
    }

    func testFilterMenuOptions_titlesAndOrder() {
        XCTAssertEqual(AppFilterOption.allCases, [.all, .runningOnly])
        XCTAssertEqual(AppFilterOption.allCases.map(\.title), ["All Apps", "Running Only"])
    }

    func testSortMenuOptions_titlesAndOrder() {
        XCTAssertEqual(AppSortOption.allCases, [.recent, .nameAscending, .nameDescending])
        XCTAssertEqual(AppSortOption.allCases.map(\.title), ["Recently Opened", "Name A-Z", "Name Z-A"])
    }

    func testAppState_defaultsMatchMenuDefaults() {
        let appState = AppDock.AppState()
        XCTAssertEqual(appState.filterOption, .all)
        XCTAssertEqual(appState.sortOption, .recent)
    }
}
