//
//  RecentAppsController.swift
//  AppDock
//
//  Created by Jared Miller on 12/5/25.
//

@testable import AppDock
import AppKit
import SwiftUI
import XCTest

// MARK: - MOCK DEPENDENCIES

/// Helper function to create a dummy NSImage for testing purposes.
func createDummyImage() -> NSImage {
    // A minimal, transparent 1x1 image is enough to verify size is set later
    let image = NSImage(size: NSSize(width: 1, height: 1))
    return image
}

/// Mock NSRunningApplication to control test data.
/// Provides configurable properties for filtering and sorting tests.
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
    init(name: String?, id: String?, urlPath: String?, policy: NSApplication.ActivationPolicy, launchDate: Date?) {
        _localizedName = name
        _bundleIdentifier = id
        if let urlPath {
            _bundleURL = URL(fileURLWithPath: urlPath)
        } else {
            _bundleURL = nil
        }
        _activationPolicy = policy
        _launchDate = launchDate
        // Call the superclass init, even though we override all accessors
        super.init()
    }
}

/// Mock NSWorkspace to return controlled application data.
// We define a protocol to allow substitution for NSWorkspace.shared
protocol TestableWorkspace {
    func runningApplications() -> [NSRunningApplication]
    func icon(forFile fullPath: String) -> NSImage
}

/// Mock implementation of the workspace.
class MockWorkspace: TestableWorkspace {
    var appsToReturn: [NSRunningApplication] = []

    func runningApplications() -> [NSRunningApplication] {
        return appsToReturn
    }

    func icon(forFile _: String) -> NSImage {
        // Return a dummy image instance
        return createDummyImage()
    }
}

/// Mock MenuController (from the previous file, simplified here).
class MockMenuController: NSObject {
    func createMenu() -> NSMenu {
        return NSMenu() // Return an empty menu for testing setup
    }
}

/// Testable AppState (to access the results).
class TestableAppState: ObservableObject {
    @Published var recentApps: [(name: String, bundleid: String, icon: NSImage)] = []
}

/// Testable AppDelegate, modified to accept a mock workspace.
// NOTE: This testable class must replicate the logic of the original AppDelegate
class TestableAppDelegate: NSObject, NSApplicationDelegate {
    // We override the singleton pattern for testing isolation
    static var instance: TestableAppDelegate!

    // We use our TestableAppState
    @Published var appState = TestableAppState()

    // Injection points for testing
    var workspace: TestableWorkspace
    var menuController: MockMenuController

    /// Convenience alias matching production app state tuples.
    typealias AppDetail = (name: String, bundleid: String, icon: NSImage)

    // NSStatusBar setup is complex to mock, we'll focus on testing that
    // the core logic (getRecentApplications) is called and functions correctly.

    init(workspace: TestableWorkspace, menuController: MockMenuController) {
        self.workspace = workspace
        self.menuController = menuController
        super.init()
        TestableAppDelegate.instance = self // Set the singleton pointer for the test
    }

    /// Replication of the original method, but using injected dependencies.
    func getRecentApplications() {
        let recentApps = workspace.runningApplications()

        let userApps = recentApps.filter { app in
            // Filter out apps that are not .regular and don't have bundle IDs
            app.activationPolicy == .regular &&
                app.bundleIdentifier != nil &&
                app.launchDate != nil
        }

        let sortedApps = userApps.sorted { app1, app2 in
            guard let date1 = app1.launchDate, let date2 = app2.launchDate else {
                return false
            }
            return date1 > date2
        }

        let appDetails = sortedApps.compactMap { app -> AppDetail? in
            makeAppEntry(from: app)
        }

        // Update the state of this test instance (skipping DispatchQueue.main.async for sync testing).
        appState.recentApps = appDetails
    }

    /// Replicates the production behavior for newly launched apps (front insert, de-dupe).
    func handleLaunchedApp(_ app: NSRunningApplication) {
        guard app.bundleIdentifier != Bundle.main.bundleIdentifier else { return }
        guard let appEntry = makeAppEntry(from: app) else { return }

        var updated = appState.recentApps
        updated.removeAll { $0.bundleid == appEntry.bundleid }
        updated.insert(appEntry, at: 0)
        appState.recentApps = updated
    }

    /// Converts a running app into a tuple matching the production `AppState`.
    private func makeAppEntry(from app: NSRunningApplication) -> AppDetail? {
        guard let appName = app.localizedName,
              let bundleid = app.bundleIdentifier,
              let appPath = app.bundleURL?.path else { return nil }

        // Use the injected workspace for icon
        let appIcon = workspace.icon(forFile: appPath)
        appIcon.size = NSSize(
            width: AppDockConstants.AppIcon.size,
            height: AppDockConstants.AppIcon.size
        )
        return (name: appName, bundleid: bundleid, icon: appIcon)
    }

    /// Exposes app entry creation for unit tests.
    func makeAppEntryForTest(from app: NSRunningApplication) -> AppDetail? {
        makeAppEntry(from: app)
    }

    /// Mimic the original method to check if getRecentApplications is called.
    func applicationDidFinishLaunching(_: Notification) {
        // Set the instance (already done in init for testing)
        // In a real app, NSStatusBar/Menu setup happens here, but we skip it.

        getRecentApplications()
    }
}

// MARK: - UNIT TESTS

/// Tests for the recent-apps filtering, sorting, and icon sizing logic.
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

    // Test 3: Verify the icon is resized to the standard app icon size
    func testGetRecentApplications_resizesIcon() {
        let now = Date()

        let app = MockRunningApplication(name: "Test App", id: "com.test.app", urlPath: "/test.app", policy: .regular, launchDate: now)

        mockWorkspace.appsToReturn = [app]

        sut.getRecentApplications()

        XCTAssertEqual(sut.appState.recentApps.count, 1)

        // The mock workspace returns a dummy image with size 1x1 initially.
        // We verify that the AppDelegate logic resized it to the standard size.
        let processedIcon = sut.appState.recentApps[0].icon

        XCTAssertEqual(
            processedIcon.size.width,
            AppDockConstants.AppIcon.size,
            "The app icon width should be resized to the standard size."
        )
        XCTAssertEqual(
            processedIcon.size.height,
            AppDockConstants.AppIcon.size,
            "The app icon height should be resized to the standard size."
        )
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

    // Test 5: Verify empty workspace yields empty state
    func testGetRecentApplications_handlesEmptyWorkspace() {
        mockWorkspace.appsToReturn = []
        sut.getRecentApplications()
        XCTAssertTrue(sut.appState.recentApps.isEmpty, "No apps should be returned when workspace is empty.")
    }

    // Test 6: Verify apps missing launchDate are skipped in sort logic (guard returns false)
    func testGetRecentApplications_skipsAppsMissingLaunchDate() {
        let now = Date()
        let validApp = MockRunningApplication(name: "Valid", id: "com.valid", urlPath: "/valid.app", policy: .regular, launchDate: now)
        let missingDate = MockRunningApplication(name: "NoDate", id: "com.nodate", urlPath: "/nodate.app", policy: .regular, launchDate: nil)

        mockWorkspace.appsToReturn = [validApp, missingDate]
        sut.getRecentApplications()

        XCTAssertEqual(sut.appState.recentApps.count, 1, "Apps missing launchDate should not survive sorting.")
        XCTAssertEqual(sut.appState.recentApps.first?.name, "Valid")
    }

    // Test 7: Verify apps missing localizedName are skipped.
    func testGetRecentApplications_skipsAppsMissingName() {
        let now = Date()
        let validApp = MockRunningApplication(name: "Valid", id: "com.valid", urlPath: "/valid.app", policy: .regular, launchDate: now)
        let missingName = MockRunningApplication(name: nil, id: "com.noname", urlPath: "/noname.app", policy: .regular, launchDate: now)

        mockWorkspace.appsToReturn = [validApp, missingName]
        sut.getRecentApplications()

        XCTAssertEqual(sut.appState.recentApps.count, 1)
        XCTAssertEqual(sut.appState.recentApps.first?.bundleid, "com.valid")
    }

    // Test 8: Verify apps missing bundle URL are skipped.
    func testGetRecentApplications_skipsAppsMissingBundleURL() {
        let now = Date()
        let validApp = MockRunningApplication(name: "Valid", id: "com.valid", urlPath: "/valid.app", policy: .regular, launchDate: now)
        let missingURL = MockRunningApplication(name: "NoURL", id: "com.nourl", urlPath: nil, policy: .regular, launchDate: now)

        mockWorkspace.appsToReturn = [validApp, missingURL]
        sut.getRecentApplications()

        XCTAssertEqual(sut.appState.recentApps.count, 1)
        XCTAssertEqual(sut.appState.recentApps.first?.bundleid, "com.valid")
    }

    // Test 9: Newly launched apps should be inserted at the front and de-duplicated.
    func testHandleLaunchedApp_insertsAndDedupes() {
        let now = Date()
        let app2 = MockRunningApplication(name: "App Two", id: "com.app.two", urlPath: "/two.app", policy: .regular, launchDate: now)

        sut.appState.recentApps = [
            ("App One", "com.app.one", createDummyImage()),
            ("App Two", "com.app.two", createDummyImage()),
        ]

        sut.handleLaunchedApp(app2)

        XCTAssertEqual(sut.appState.recentApps.count, 2)
        XCTAssertEqual(sut.appState.recentApps.first?.bundleid, "com.app.two")
        XCTAssertEqual(sut.appState.recentApps.last?.bundleid, "com.app.one")
    }

    // Test 10: Newly launched apps should be added when the list is empty.
    func testHandleLaunchedApp_insertsWhenEmpty() {
        let now = Date()
        let app = MockRunningApplication(name: "Fresh App", id: "com.app.fresh", urlPath: "/fresh.app", policy: .regular, launchDate: now)

        sut.appState.recentApps = []
        sut.handleLaunchedApp(app)

        XCTAssertEqual(sut.appState.recentApps.count, 1)
        XCTAssertEqual(sut.appState.recentApps.first?.bundleid, "com.app.fresh")
    }

    // Test 11: handleLaunchedApp should ignore apps without required fields.
    func testHandleLaunchedApp_ignoresIncompleteApp() {
        let now = Date()
        let missingURL = MockRunningApplication(name: "NoURL", id: "com.nourl", urlPath: nil, policy: .regular, launchDate: now)

        sut.appState.recentApps = [("Existing", "com.existing", createDummyImage())]
        sut.handleLaunchedApp(missingURL)

        XCTAssertEqual(sut.appState.recentApps.count, 1)
        XCTAssertEqual(sut.appState.recentApps.first?.bundleid, "com.existing")
    }

    // Test 12: handleLaunchedApp should ignore the AppDock bundle identifier when available.
    func testHandleLaunchedApp_ignoresMainBundleId() {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return
        }
        let now = Date()
        let app = MockRunningApplication(name: "AppDock", id: bundleId, urlPath: "/appdock.app", policy: .regular, launchDate: now)

        sut.appState.recentApps = []
        sut.handleLaunchedApp(app)

        XCTAssertTrue(sut.appState.recentApps.isEmpty)
    }
}
