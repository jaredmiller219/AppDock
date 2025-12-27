import XCTest
import SwiftUI
@testable import AppDock

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
        var quitCalled = false
        
        let popVC = controller.makePopoverController(
            appState: appState,
            menuState: menuState,
            settingsAction: { settingsCalled = true },
            aboutAction: { aboutCalled = true },
            quitAction: { quitCalled = true }
        )
        
        guard let hosting = popVC as? NSHostingController<PopoverContentView> else {
            XCTFail("Popover controller should be an NSHostingController<PopoverContentView>")
            return
        }
        
        // Trigger actions directly through the view's closures
        hosting.rootView.settingsAction()
        hosting.rootView.aboutAction()
        hosting.rootView.quitAction()
        
        XCTAssertTrue(settingsCalled, "Settings action should be wired.")
        XCTAssertTrue(aboutCalled, "About action should be wired.")
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
