import XCTest
import SwiftUI
@testable import AppDock

final class MenuControllerTests: XCTestCase {
    
    // Verify the hosting controller is created with the expected size and root view
    func testMakePopoverController_returnsHostingControllerWithSize() {
        let controller = MenuController()
        let appState = AppDock.AppState()
        
        let popVC = controller.makePopoverController(
            appState: appState,
            settingsAction: {},
            aboutAction: {},
            quitAction: {}
        )
        
        guard let hosting = popVC as? NSHostingController<PopoverContentView> else {
            XCTFail("Popover controller should be an NSHostingController<PopoverContentView>")
            return
        }
        
        XCTAssertEqual(hosting.view.frame.size.width, 220, accuracy: 0.1)
        XCTAssertEqual(hosting.view.frame.size.height, 380, accuracy: 0.1)
        XCTAssertTrue(hosting.rootView.appState === appState)
    }
    
    // Verify button actions are wired through the view
    func testMakePopoverController_wiresActions() {
        let controller = MenuController()
        let appState = AppDock.AppState()
        var settingsCalled = false
        var aboutCalled = false
        var quitCalled = false
        
        let popVC = controller.makePopoverController(
            appState: appState,
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
}
