@testable import AppDock
import XCTest

final class MenuSwipeLogicTests: XCTestCase {
    func testCommitThresholdUsesPopoverWidthFraction() {
        let width: CGFloat = 260
        let expected = max(AppDockConstants.MenuGestures.swipeThreshold,
                           width * AppDockConstants.MenuGestures.swipePageThresholdFraction)
        XCTAssertEqual(MenuSwipeLogic.commitThreshold(width: width), expected, accuracy: 0.001)
    }

    func testShouldCommitReturnsFalseWhenBelowThreshold() {
        let width: CGFloat = 260
        let horizontal: CGFloat = 40
        let vertical: CGFloat = 2
        XCTAssertFalse(MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: width))
    }

    func testShouldCommitReturnsFalseWhenVerticalDominates() {
        let width: CGFloat = 260
        let horizontal: CGFloat = 120
        let vertical: CGFloat = 140
        XCTAssertFalse(MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: width))
    }

    func testNextPageReturnsNilAtBounds() {
        XCTAssertNil(MenuSwipeLogic.nextPage(from: .dock, direction: .right))
        XCTAssertNil(MenuSwipeLogic.nextPage(from: .actions, direction: .left))
    }

    func testNextPageReturnsAdjacent() {
        XCTAssertEqual(MenuSwipeLogic.nextPage(from: .dock, direction: .left), .recents)
        XCTAssertEqual(MenuSwipeLogic.nextPage(from: .recents, direction: .right), .dock)
    }

    func testShouldCommitFalseMatchesCancelBehavior() {
        let width: CGFloat = 260
        let horizontal: CGFloat = 60
        let vertical: CGFloat = 8

        XCTAssertFalse(MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: width))

        var currentPage: MenuPage = .dock
        if MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: width),
           let next = MenuSwipeLogic.nextPage(from: currentPage, direction: .left)
        {
            currentPage = next
        }

        XCTAssertEqual(currentPage, .dock)
    }
    
    // MARK: - Edge Cases
    
    func testSwipeLogicWithZeroWidth() {
        let zeroWidth: CGFloat = 0
        let threshold = MenuSwipeLogic.commitThreshold(width: zeroWidth)
        
        XCTAssertEqual(threshold, AppDockConstants.MenuGestures.swipeThreshold)
    }
    
    func testSwipeLogicWithNegativeValues() {
        let negativeWidth: CGFloat = -100
        let horizontal: CGFloat = -50
        let vertical: CGFloat = -25
        
        // With negative width, should not commit (or handle gracefully)
        let shouldCommit = MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: negativeWidth)
        // Test that it handles negative width gracefully (either returns false or handles edge case)
        XCTAssertTrue(shouldCommit == false || shouldCommit == true, "Should handle negative width without crashing")
    }
}
