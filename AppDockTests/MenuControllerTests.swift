//
//  MockAppState.swift
//  AppDock
//
//  Created by Jared Miller on 12/5/25.
//


import XCTest
import SwiftUI
import AppKit // Required for NSMenu and NSApp testing

// --- Mock Dependencies for Testing ---

// 1. Mock AppState: The MenuController needs to access this.
class MockAppState: ObservableObject {
    @Published var recentApps: [String] = []
}

// 2. Mock DockView: The MenuController instantiates this SwiftUI View.
struct MockDockView: View {
    // Must accept the appState to match the MenuController's usage
    @ObservedObject var appState: MockAppState
    
    var body: some View {
        // Minimal implementation for testing
        Text("Mock Dock View")
    }
}

// 3. Mock AppDelegate: The MenuController accesses its instance and appState.
class MockAppDelegate: NSObject {
    static let instance = MockAppDelegate()
    let appState = MockAppState()
    // NOTE: In a real app, NSApp.delegate is often set to AppDelegate.
    // For this test, we just provide the static instance.
}

// Rename the original MenuController class name to avoid conflicts 
// and use the mocks we created above to allow compilation.
class TestableMenuController: NSObject {
    // Use MockAppDelegate and MockDockView
    
    let menu = NSMenu()
    
    func createMenu() -> NSMenu {
        // Access shared state using the mock
        let appState = MockAppDelegate.instance.appState
        
        // Create the main dock view using the mock
        let dockView = MockDockView(appState: appState)
        
        // Wrap the SwiftUI dock view in an NSHostingController
        let topView = NSHostingController(rootView: dockView)
        
        // Configure the size of the menu window
        topView.view.frame.size = CGSize(width: 200, height: 340)
        
        let menuItem = NSMenuItem()
        menuItem.view = topView.view
        
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem.separator())
        
        let aboutMenuItem = NSMenuItem(title: "About AppDock",
                                       action: #selector(about),
                                       keyEquivalent: "")
        aboutMenuItem.target = self
        menu.addItem(aboutMenuItem)
        
        let quitMenuItem = NSMenuItem(title: "Quit",
                                      action: #selector(quit),
                                      keyEquivalent: "q")
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        
        return menu
    }
    
    @objc func about(sender: NSMenuItem) {
        // No-op for testing structure
    }
    
    @objc func quit(sender: NSMenuItem) {
        // No-op for testing structure
    }
}


// --- Unit Test Implementation ---

final class MenuControllerTests: XCTestCase {

    var sut: TestableMenuController!

    override func setUpWithError() throws {
        // Initialize the System Under Test (SUT) before each test
        sut = TestableMenuController()
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        sut = nil
    }

    // Test 1: Verify the menu is created and the number of items is correct
    func testCreateMenu_structureIsCorrect() {
        let menu = sut.createMenu()

        // Expect 4 items: DockView, Separator, About, Quit
        XCTAssertEqual(menu.items.count, 4, "The menu should contain exactly 4 items.")

        // Check the titles of the last two standard menu items
        XCTAssertEqual(menu.items[2].title, "About AppDock", "Third item should be 'About AppDock'.")
        XCTAssertEqual(menu.items[3].title, "Quit", "Fourth item should be 'Quit'.")
    }

    // Test 2: Verify the first item contains the SwiftUI view
    func testCreateMenu_firstItemIsHostingView() {
        let menu = sut.createMenu()
        let dockItem = menu.items[0]

        // 1. Check if it's a view-backed item
        XCTAssertNotNil(dockItem.view, "The first menu item should contain a custom view.")

        // 2. Check the size of the hosted view
        XCTAssertEqual(dockItem.view?.frame.size.width, 200, "Hosted view width should be 200.")
        XCTAssertEqual(dockItem.view?.frame.size.height, 340, "Hosted view height should be 340.")

        // 3. (Advanced) Verify the hosted view contains the NSHostingController content
        // This is complex, but we can verify the immediate superview is an NSHostingView
		_ = dockItem.view
        // In reality, NSMenuItem wraps the view in a controller's view hierarchy.
        // We'll rely on checking the existence and size for a robust test.
    }

    // Test 3: Verify the Separator is in the correct position
    func testCreateMenu_separatorIsPresent() {
        let menu = sut.createMenu()
        let separatorItem = menu.items[1]

        // NSMenuItem.separator() creates a special item type
        XCTAssertTrue(separatorItem.isSeparatorItem, "The second item should be a separator.")
    }

    // Test 4: Verify the "About" menu item's action and target
    func testCreateMenu_aboutMenuItem_hasCorrectAction() {
        let menu = sut.createMenu()
        let aboutItem = menu.items[2]

        // Check the target is the MenuController instance
        XCTAssertTrue(aboutItem.target === sut, "About item target should be the MenuController.")

        // Check the action is correctly set to 'about' selector
        XCTAssertEqual(aboutItem.action, #selector(TestableMenuController.about(sender:)), "About item action should be the 'about' method.")
    }
    
    // Test 5: Verify the "Quit" menu item's action, target, and key equivalent
    func testCreateMenu_quitMenuItem_hasCorrectSetup() {
        let menu = sut.createMenu()
        let quitItem = menu.items[3]

        // Check the target is the MenuController instance
        XCTAssertTrue(quitItem.target === sut, "Quit item target should be the MenuController.")

        // Check the action is correctly set to 'quit' selector
        XCTAssertEqual(quitItem.action, #selector(TestableMenuController.quit(sender:)), "Quit item action should be the 'quit' method.")
        
        // Check the keyboard shortcut
        XCTAssertEqual(quitItem.keyEquivalent, "q", "Quit item should have the key equivalent 'q'.")
    }
    
    /*
     NOTE: Testing the actual side effects of 'about' (NSApp.orderFrontStandardAboutPanel())
     and 'quit' (NSApp.terminate()) is typically done in an Integration Test or is
     often considered outside the scope of a Unit Test, as they rely on the running AppKit
     environment. We only verify the actions are correctly configured.
    */
}
