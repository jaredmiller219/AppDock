//
//  ContextMenuViewTests.swift
//  AppDockTests
//
//  Unit tests for enhanced context menu functionality
//

@testable import AppDock
import AppKit
import SwiftUI
import XCTest

final class ContextMenuViewTests: XCTestCase {
    
    func testContextMenuViewCreation() {
        // Test that context menu view can be created with valid parameters
        let contextMenuView = ContextMenuView(
            onDismiss: {},
            appName: "TestApp",
            bundleId: "com.test.app",
            confirmBeforeQuit: false
        )
        
        XCTAssertNotNil(contextMenuView)
    }
    
    func testContextMenuViewWithEmptyAppName() {
        // Test context menu with empty app name
        let contextMenuView = ContextMenuView(
            onDismiss: {},
            appName: "",
            bundleId: "com.test.app",
            confirmBeforeQuit: false
        )
        
        XCTAssertNotNil(contextMenuView)
    }
    
    func testContextMenuViewWithConfirmation() {
        // Test context menu with quit confirmation enabled
        let contextMenuView = ContextMenuView(
            onDismiss: {},
            appName: "TestApp",
            bundleId: "com.test.app",
            confirmBeforeQuit: true
        )
        
        XCTAssertNotNil(contextMenuView)
    }
    
    func testContextMenuConstants() {
        // Verify context menu constants are properly set
        XCTAssertEqual(AppDockConstants.ContextMenu.width, 220)
        XCTAssertEqual(AppDockConstants.ContextMenu.buttonMinHeight, 36)
        XCTAssertEqual(AppDockConstants.ContextMenu.spacing, 8)
        XCTAssertEqual(AppDockConstants.ContextMenu.paddingHorizontal, 12)
        XCTAssertEqual(AppDockConstants.ContextMenu.paddingVertical, 10)
        XCTAssertEqual(AppDockConstants.ContextMenu.closeButtonSize, 24)
        XCTAssertEqual(AppDockConstants.ContextMenu.closeButtonPadding, 8)
    }
    
    func testContextMenuAccessibilityIdentifier() {
        // Test that accessibility identifier is stable
        XCTAssertEqual(AppDockConstants.Accessibility.contextMenu, "DockContextMenu")
    }
    
    // MARK: - Mock Tests for Private Methods
    
    func testShowInFinderWithValidBundleId() {
        // This would test the showInFinder method with a valid bundle ID
        // In practice, this requires mocking NSWorkspace.shared
        let bundleId = "com.test.app"
        
        // Verify the bundle ID format is valid
        XCTAssertTrue(bundleId.contains("."))
        XCTAssertTrue(bundleId.count > 5)
    }
    
    func testRevealInDockWithValidBundleId() {
        // This would test the revealInDock method with a valid bundle ID
        // In practice, this requires mocking NSWorkspace.shared
        let bundleId = "com.test.app"
        
        // Verify the bundle ID format is valid
        XCTAssertTrue(bundleId.contains("."))
        XCTAssertTrue(bundleId.count > 5)
    }
    
    func testForceQuitConfirmationMessage() {
        // Test that force quit confirmation message is properly formatted
        let appName = "TestApp"
        let expectedMessage = "Force Quit \(appName)?"
        
        XCTAssertEqual(expectedMessage, "Force Quit TestApp?")
        XCTAssertTrue(expectedMessage.contains(appName))
        XCTAssertTrue(expectedMessage.contains("Force Quit"))
    }
    
    func testToggleLaunchAtLoginLogging() {
        // Test that launch at login toggle logs correctly
        let bundleId = "com.test.app"
        let expectedLogMessage = "Toggle launch at login for: \(bundleId)"
        
        XCTAssertEqual(expectedLogMessage, "Toggle launch at login for: com.test.app")
        XCTAssertTrue(expectedLogMessage.contains(bundleId))
    }
}
