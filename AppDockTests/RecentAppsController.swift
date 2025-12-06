//
//  MockRunningApplication.swift
//  AppDock
//
//  Created by Jared Miller on 12/5/25.
//


import XCTest
import SwiftUI
import AppKit

// MARK: - MOCK DEPENDENCIES

// Helper function to create a dummy NSImage for testing purposes
func createDummyImage() -> NSImage {
    // A minimal, transparent 1x1 image is enough to verify size is set later
    let image = NSImage(size: NSSize(width: 1, height: 1))
    return image
}

// 1. Mock NSRunningApplication to control test data
class MockRunningApplication: NSRunningApplication, @unchecked Sendable {
    // We must use 'override' and provide storage for the properties
    private let _localizedName: String?
    private let _bundleIdentifier: String?
    private let _bundleURL: URL?
    private let _activationPolicy: NSApplication.ActivationPolicy
    private let _launchDate: Date?

    override var localizedName: String? { _localizedName }
    override var bundleIdentifier: String? { _bundleIdentifier }
    override var bundleURL: URL? { _bundleURL }
    override var activationPolicy: NSApplication.ActivationPolicy { _activationPolicy }
    override var launchDate: Date? { _launchDate }

    // Custom initializer to set all required properties
    init(name: String, id: String?, urlPath: String, policy: NSApplication.ActivationPolicy, launchDate: Date?) {
        self._localizedName = name
        self._bundleIdentifier = id
        self._bundleURL = URL(fileURLWithPath: urlPath)
        self._activationPolicy = policy
        self._launchDate = launchDate
        // Call the superclass init, even though we override all accessors
        super.init()
    }
}

// 2. Mock NSWorkspace to return controlled application data
// We define a protocol to allow substitution for NSWorkspace.shared
protocol TestableWorkspace {
    func runningApplications() -> [NSRunningApplication]
    func icon(forFile fullPath: String) -> NSImage
}

// Mock implementation of the workspace
class MockWorkspace: TestableWorkspace {
    var appsToReturn: [NSRunningApplication] = []

    func runningApplications() -> [NSRunningApplication] {
        return appsToReturn
    }

    func icon(forFile fullPath: String) -> NSImage {
        // Return a dummy image instance
        return createDummyImage()
    }
}

// 3. Mock MenuController (from the previous file, simplified here)
class MockMenuController: NSObject {
    func createMenu() -> NSMenu {
        return NSMenu() // Return an empty menu for testing setup
    }
}

// 4. Testable AppState (to access the results)
class TestableAppState: ObservableObject {
    @Published var recentApps: [(name: String, bundleid: String, icon: NSImage)] = []
}

// 5. Testable AppDelegate, modified to accept a mock workspace
// NOTE: This testable class must replicate the logic of the original AppDelegate
class TestableAppDelegate: NSObject, NSApplicationDelegate {
    
    // We override the singleton pattern for testing isolation
    static var instance: TestableAppDelegate!
    
    // We use our TestableAppState
    @Published var appState = TestableAppState()
    
    // Injection points for testing
    var workspace: TestableWorkspace
    var menuController: MockMenuController
    
    // NSStatusBar setup is complex to mock, we'll focus on testing that
    // the core logic (getRecentApplications) is called and functions correctly.
    
    init(workspace: TestableWorkspace, menuController: MockMenuController) {
        self.workspace = workspace
        self.menuController = menuController
        super.init()
        TestableAppDelegate.instance = self // Set the singleton pointer for the test
    }
    
    // Replication of the original method, but using injected dependencies
    func getRecentApplications() {
        
        let recentApps = self.workspace.runningApplications()

        let userApps = recentApps.filter { app in
            // Filter out apps that are not .regular and don't have bundle IDs
            app.activationPolicy == .regular && app.bundleIdentifier != nil
        }

        let sortedApps = userApps.sorted { app1, app2 in
            guard let date1 = app1.launchDate, let date2 = app2.launchDate else {
                return false
            }
            return date1 > date2
        }

        let appDetails = sortedApps.compactMap { app -> (String, String, NSImage)? in
            guard let appName = app.localizedName,
                  let bundleid = app.bundleIdentifier,
                  let appPath = app.bundleURL?.path else { return nil }
            
            // Use the injected workspace for icon
            let appIcon = self.workspace.icon(forFile: appPath)
            
            // Icon resizing logic
            appIcon.size = NSSize(width: 64, height: 64)
            
            return (appName, bundleid, appIcon)
        }

        // Update the state of this test instance (skipping DispatchQueue.main.async for sync testing)
        self.appState.recentApps = appDetails
    }
    
    // Mimic the original method to check if getRecentApplications is called
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set the instance (already done in init for testing)
        // In a real app, NSStatusBar/Menu setup happens here, but we skip it.
        
        getRecentApplications()
    }
}


// MARK: - UNIT TESTS

final class AppDelegateLogicTests: XCTestCase {

    var mockWorkspace: MockWorkspace!
    var mockMenuController: MockMenuController!
    var sut: TestableAppDelegate! // System Under Test

    override func setUpWithError() throws {
        mockWorkspace = MockWorkspace()
        mockMenuController = MockMenuController()
        sut = TestableAppDelegate(workspace: mockWorkspace, menuController: mockMenuController)
    }

    override func tearDownWithError() throws {
        mockWorkspace = nil
        mockMenuController = nil
        sut = nil
        TestableAppDelegate.instance = nil // Clean up the static instance
    }

    // Test 1: Verify filtering by activationPolicy and bundleIdentifier
    func testGetRecentApplications_filtersCorrectly() {
        let now = Date()
        
        // 1. Valid user app
        let app1 = MockRunningApplication(name: "App A", id: "com.app.a", urlPath: "/a.app", policy: .regular, launchDate: now.addingTimeInterval(-100))
        
        // 2. System/background app (should be filtered out)
        let app2 = MockRunningApplication(name: "App B", id: "com.app.b", urlPath: "/b.app", policy: .accessory, launchDate: now.addingTimeInterval(-50))
        
        // 3. App missing bundle ID (should be filtered out)
        let app3 = MockRunningApplication(name: "App C", id: nil, urlPath: "/c.app", policy: .regular, launchDate: now.addingTimeInterval(-200))
        
        // 4. Valid user app
        let app4 = MockRunningApplication(name: "App D", id: "com.app.d", urlPath: "/d.app", policy: .regular, launchDate: now.addingTimeInterval(-150))
        
        mockWorkspace.appsToReturn = [app1, app2, app3, app4]

        sut.getRecentApplications()

        // Only app1 and app4 should remain
        XCTAssertEqual(sut.appState.recentApps.count, 2, "Should filter out system apps and apps without bundle IDs.")
        XCTAssertEqual(sut.appState.recentApps.map { $0.name }.contains("App B"), false)
        XCTAssertEqual(sut.appState.recentApps.map { $0.name }.contains("App C"), false)
    }

    // Test 2: Verify sorting by launchDate (most recent first)
    func testGetRecentApplications_sortsByLaunchDate() {
        let now = Date()
        
        // App 1: Oldest
        let app1 = MockRunningApplication(name: "Oldest App", id: "com.oldest.app", urlPath: "/oldest.app", policy: .regular, launchDate: now.addingTimeInterval(-300))
        
        // App 2: Newest
        let app2 = MockRunningApplication(name: "Newest App", id: "com.newest.app", urlPath: "/newest.app", policy: .regular, launchDate: now.addingTimeInterval(-50))
        
        // App 3: Middle
        let app3 = MockRunningApplication(name: "Middle App", id: "com.middle.app", urlPath: "/middle.app", policy: .regular, launchDate: now.addingTimeInterval(-150))
        
        mockWorkspace.appsToReturn = [app1, app2, app3] // Input in random order

        sut.getRecentApplications()

        // Expect: Newest, Middle, Oldest
        XCTAssertEqual(sut.appState.recentApps.count, 3, "All apps should be included.")
        XCTAssertEqual(sut.appState.recentApps[0].name, "Newest App", "The first app should be the most recently launched.")
        XCTAssertEqual(sut.appState.recentApps[1].name, "Middle App")
        XCTAssertEqual(sut.appState.recentApps[2].name, "Oldest App", "The last app should be the least recently launched.")
    }
    
    // Test 3: Verify the icon is resized to 64x64
    func testGetRecentApplications_resizesIcon() {
        let now = Date()
        
        let app = MockRunningApplication(name: "Test App", id: "com.test.app", urlPath: "/test.app", policy: .regular, launchDate: now)
        
        mockWorkspace.appsToReturn = [app]

        sut.getRecentApplications()
        
        XCTAssertEqual(sut.appState.recentApps.count, 1)
        
        // The mock workspace returns a dummy image with size 1x1 initially.
        // We verify that the AppDelegate logic resized it to 64x64.
        let processedIcon = sut.appState.recentApps[0].icon
        
        XCTAssertEqual(processedIcon.size.width, 64.0, "The app icon width should be resized to 64.")
        XCTAssertEqual(processedIcon.size.height, 64.0, "The app icon height should be resized to 64.")
    }
    
    // Test 4: Verify applicationDidFinishLaunching calls the data retrieval method
    func testApplicationDidFinishLaunching_callsGetRecentApplications() {
        // Since getRecentApplications updates appState, we can check the state change
        // by making the workspace return an app.
        let app = MockRunningApplication(name: "App X", id: "com.app.x", urlPath: "/x.app", policy: .regular, launchDate: Date())
        mockWorkspace.appsToReturn = [app]
        
        // State should be empty before launch
        XCTAssertTrue(sut.appState.recentApps.isEmpty)
        
        // Call the setup method
        sut.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        
        // State should now contain the app, proving getRecentApplications was called
        XCTAssertEqual(sut.appState.recentApps.count, 1, "AppDelegate should call getRecentApplications during launch.")
        XCTAssertEqual(sut.appState.recentApps.first?.name, "App X")
    }
}
