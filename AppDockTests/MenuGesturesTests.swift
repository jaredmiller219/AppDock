import XCTest
@testable import AppDock

final class MenuGesturesTests: XCTestCase {
    func testMenuGestureConstants_haveExpectedDefaults() {
        XCTAssertEqual(AppDockConstants.MenuGestures.swipeThreshold, 30)
        XCTAssertEqual(AppDockConstants.MenuGestures.dragMinimumDistance, 12)
        XCTAssertEqual(AppDockConstants.MenuGestures.swipePageThresholdFraction, 0.5)
        XCTAssertEqual(AppDockConstants.MenuGestures.dragCancelDuration, 0.35, accuracy: 0.001)
        XCTAssertEqual(AppDockConstants.MenuGestures.dragCommitDuration, 0.28, accuracy: 0.001)
    }

    func testMenuGestureThresholdFractionIsValid() {
        XCTAssertGreaterThanOrEqual(AppDockConstants.MenuGestures.swipePageThresholdFraction, 0.0)
        XCTAssertLessThanOrEqual(AppDockConstants.MenuGestures.swipePageThresholdFraction, 1.0)
    }
}
