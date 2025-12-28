@testable import AppDock
import XCTest

final class AppDockConstantsTests: XCTestCase {
    func testSettingsUISizes() {
        XCTAssertEqual(AppDockConstants.SettingsUI.sidebarWidth, 160)
        XCTAssertEqual(AppDockConstants.SettingsUI.minWidth, 560)
        XCTAssertEqual(AppDockConstants.SettingsUI.minHeight, 560)
    }

    func testAppIconAndStatusBarSizes() {
        XCTAssertEqual(AppDockConstants.AppIcon.size, 64)
        XCTAssertEqual(AppDockConstants.StatusBarIcon.size, 18)
    }

    func testMenuGesturesThresholds() {
        XCTAssertEqual(AppDockConstants.MenuGestures.swipeThreshold, 30)
        XCTAssertEqual(AppDockConstants.MenuGestures.swipePageThresholdFraction, 0.4, accuracy: 0.0001)
    }

    func testMenuPopoverDefaults() {
        XCTAssertEqual(AppDockConstants.MenuPopover.defaultWidth, 260)
        XCTAssertEqual(AppDockConstants.MenuPopover.height, 460)
    }
}
