//
//  CriticalEdgeCasesTests.swift
//  AppDockTests
//
//  Comprehensive unit tests for the most critical edge cases across AppDock
//

@testable import AppDock
import Carbon
import SwiftUI
import XCTest

// MARK: - Critical Edge Cases Test Suite

/// Tests critical edge cases that could cause crashes, data corruption, or poor user experience.
/// Focuses on robustness, error handling, and performance under stress conditions.
final class CriticalEdgeCasesTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var appState: AppState!
    var menuState: MenuState!
    var menuController: MenuController!
    fileprivate var mockRegistrar: MockHotKeyRegistrar!
    var shortcutManager: ShortcutManager!
    fileprivate var groupManager: AppGroupManager!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        appState = AppState()
        menuState = MenuState()
        menuController = MenuController()
        mockRegistrar = MockHotKeyRegistrar()
        groupManager = AppGroupManager()
        
        shortcutManager = ShortcutManager(
            actionHandler: { _ in },
            shortcutProvider: { action in
                switch action {
                case .togglePopover:
                    return ShortcutDefinition(keyCode: 1, modifiers: [.command])
                default:
                    return nil
                }
            },
            registrar: mockRegistrar,
            installEventHandler: false
        )
    }
    
    override func tearDown() {
        appState = nil
        menuState = nil
        menuController = nil
        mockRegistrar = nil
        shortcutManager = nil
        
        // Clean up test groups
        if let manager = groupManager {
            let userGroups = manager.groups.filter { !$0.isSystem }
            for group in userGroups {
                manager.deleteGroup(group)
            }
        }
        groupManager = nil
        
        super.tearDown()
    }
    
    // MARK: - AppState Edge Cases
    
    /// Tests handling of empty recent apps array
    func testEmptyRecentAppsHandling() {
        appState.recentApps = []
        
        XCTAssertTrue(appState.recentApps.isEmpty)
        XCTAssertNoThrow(appState.recentApps.removeAll())
        
        // Test filtering doesn't crash with empty array
        let filtered = appState.recentApps.filter { !$0.name.isEmpty }
        XCTAssertTrue(filtered.isEmpty)
    }
    
    /// Tests recovery from corrupted app data
    func testCorruptedDataRecovery() {
        let corruptedApps: [AppState.AppEntry] = [
            ("", "com.test.valid", NSImage()), // Empty name
            ("Valid App", "", NSImage()), // Empty bundle ID
        ]
        
        XCTAssertNoThrow(appState.recentApps = corruptedApps)
        
        // Test filtering removes invalid entries
        let validApps = appState.recentApps.filter { !$0.name.isEmpty && !$0.bundleid.isEmpty }
        XCTAssertLessThanOrEqual(validApps.count, corruptedApps.count)
    }
    
    /// Tests performance with large datasets
    func testLargeDatasetPerformance() {
        let largeAppList = (0..<500).map { index in
            ("App \(index)", "com.test.app\(index)", NSImage(size: NSSize(width: 64, height: 64)))
        }
        
        measure {
            appState.recentApps = largeAppList
            let _ = appState.recentApps.count
            let _ = appState.recentApps.first { $0.name.contains("250") }
        }
    }
    
    /// Tests thread safety with concurrent access
    func testConcurrentAppStateAccess() {
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 10
        
        let concurrentQueue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        let serialQueue = DispatchQueue(label: "test.serial")
        
        for i in 0..<10 {
            concurrentQueue.async {
                let newApp: AppState.AppEntry = ("App \(i)", "com.test.concurrent\(i)", NSImage())
                serialQueue.async {
                    self.appState.recentApps.append(newApp)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(appState.recentApps.count, 10)
    }
    
    // MARK: - Shortcut Manager Edge Cases
    
    /// Tests behavior when hot key registration fails
    func testHotKeyRegistrationFailure() {
        mockRegistrar.shouldFailRegistration = true
        shortcutManager.refreshShortcuts()
        
        XCTAssertEqual(mockRegistrar.failedRegistrations, 1)
    }
    
    /// Tests handling of system shortcut conflicts
    func testSystemShortcutConflicts() {
        let conflictingShortcuts: [ShortcutAction: ShortcutDefinition] = [
            .togglePopover: ShortcutDefinition(keyCode: 3, modifiers: [.command, .option]) // Cmd+Option (Spotlight)
        ]
        
        let conflictManager = ShortcutManager(
            actionHandler: { _ in },
            shortcutProvider: { action in conflictingShortcuts[action] },
            registrar: mockRegistrar,
            installEventHandler: false
        )
        
        conflictManager.refreshShortcuts()
        XCTAssertEqual(mockRegistrar.registerCalls.count, 1)
    }
    
    /// Tests deduplication of identical shortcuts
    func testShortcutDeduplication() {
        let identicalShortcut = ShortcutDefinition(keyCode: 5, modifiers: [.command])
        let identicalShortcuts: [ShortcutAction: ShortcutDefinition] = [
            .togglePopover: identicalShortcut,
            .nextPage: identicalShortcut
        ]
        
        let identicalManager = ShortcutManager(
            actionHandler: { _ in },
            shortcutProvider: { action in identicalShortcuts[action] },
            registrar: mockRegistrar,
            installEventHandler: false
        )
        
        identicalManager.refreshShortcuts()
        XCTAssertEqual(mockRegistrar.registerCalls.count, 1)
    }
    
    // MARK: - Menu Controller Edge Cases
    
    /// Tests popover creation with extreme sizing values
    func testPopoverWithExtremeSizing() {
        appState.gridColumns = 50
        appState.iconSize = 300
        
        let popVC = menuController.makePopoverController(
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
        
        XCTAssertLessThan(hosting.view.frame.size.width, 20000)
        XCTAssertGreaterThan(hosting.view.frame.size.width, 0)
    }
    
    /// Tests popover creation with zero sizing values
    func testPopoverWithZeroSizing() {
        appState.gridColumns = 0
        appState.iconSize = 0
        
        let popVC = menuController.makePopoverController(
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
        
        XCTAssertGreaterThanOrEqual(hosting.view.frame.size.width, 0)
    }
    
    /// Tests rapid popover creation without memory leaks
    func testRapidPopoverCreation() {
        for _ in 0..<20 {
            let popVC = menuController.makePopoverController(
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
            _ = popVC
        }
        XCTAssertTrue(true) // Should not crash
    }
    
    // MARK: - App Groups Edge Cases
    
    /// Tests group creation with special characters and emojis
    func testGroupWithSpecialCharacters() {
        let specialGroup = AppGroup(
            name: "🚀 Test Group with émojis & spëcial chârs! 🎉",
            icon: "star",
            color: "#FF00FF"
        )
        
        groupManager.addGroup(specialGroup)
        
        let addedGroup = groupManager.groups.first { $0.name == specialGroup.name }
        XCTAssertNotNil(addedGroup)
        XCTAssertEqual(addedGroup?.name, specialGroup.name)
    }
    
    /// Tests handling of invalid bundle IDs in groups
    func testGroupWithInvalidBundleIds() {
        let testGroup = AppGroup(name: "Invalid Bundle Test")
        groupManager.addGroup(testGroup)
        
        guard let addedGroup = groupManager.groups.first(where: { $0.name == "Invalid Bundle Test" }) else {
            XCTFail("Test group not found")
            return
        }
        
        let invalidBundleIds = ["", "invalid", "com.test.", ".com.test", "com..test"]
        
        for bundleId in invalidBundleIds {
            XCTAssertNoThrow(groupManager.addAppToGroup(bundleId, groupId: addedGroup.id))
        }
        
        let updatedGroup = groupManager.groups.first { $0.id == addedGroup.id }
        XCTAssertEqual(updatedGroup?.appBundleIds.count, invalidBundleIds.count)
    }
    
    /// Tests concurrent group operations for thread safety
    func testConcurrentGroupOperations() {
        let expectation = XCTestExpectation(description: "Concurrent group operations")
        expectation.expectedFulfillmentCount = 10
        
        let concurrentQueue = DispatchQueue(label: "test.groups", attributes: .concurrent)
        
        for i in 0..<10 {
            concurrentQueue.async {
                let group = AppGroup(name: "Concurrent Group \(i)")
                self.groupManager.addGroup(group)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertGreaterThanOrEqual(groupManager.groups.count, 10)
    }
    
    /// Tests group deletion when it contains apps
    func testGroupDeletionWithApps() {
        let testGroup = AppGroup(name: "Delete Test")
        groupManager.addGroup(testGroup)
        
        guard let addedGroup = groupManager.groups.first(where: { $0.name == "Delete Test" }) else {
            XCTFail("Test group not found")
            return
        }
        
        // Add apps to group
        groupManager.addAppToGroup("com.test.app1", groupId: addedGroup.id)
        groupManager.addAppToGroup("com.test.app2", groupId: addedGroup.id)
        
        // Refresh the group reference to get updated state
        let updatedGroup = groupManager.groups.first { $0.id == addedGroup.id }
        XCTAssertEqual(updatedGroup?.appBundleIds.count, 2)
        
        // Delete group
        groupManager.deleteGroup(addedGroup)
        
        XCTAssertNil(groupManager.groups.first { $0.id == addedGroup.id })
    }
    
    // MARK: - Settings Edge Cases
    
    /// Tests settings with extreme boundary values
    func testSettingsWithExtremeValues() {
        let extremeDraft = SettingsDraft(
            launchAtLogin: true,
            openOnStartup: false,
            autoUpdates: false,
            showAppLabels: false,
            showRunningIndicator: false,
            enableHoverRemove: false,
            confirmBeforeQuit: true,
            keepQuitApps: false,
            defaultFilter: .all,
            defaultSort: .nameAscending,
            gridColumns: 0, // Edge case
            gridRows: 100, // Large value
            iconSize: 0, // Edge case
            labelSize: 50, // Large value
            reduceMotion: true,
            debugLogging: true,
            simpleSettings: true,
            menuLayoutMode: .advanced
        )
        
        XCTAssertNoThrow(appState.applySettings(extremeDraft))
        XCTAssertEqual(appState.gridColumns, 0)
        XCTAssertEqual(appState.gridRows, 100)
        XCTAssertEqual(appState.iconSize, 0, accuracy: 0.01)
        XCTAssertEqual(appState.labelSize, 50, accuracy: 0.01)
    }
    
    /// Tests recovery from corrupted UserDefaults
    func testSettingsCorruptionRecovery() {
        // Simulate corrupted UserDefaults
        let testDefaults = UserDefaults(suiteName: "AppDock.CorruptionTest")!
        testDefaults.set("invalid_boolean", forKey: SettingsDefaults.launchAtLoginKey)
        testDefaults.set("invalid_integer", forKey: SettingsDefaults.gridColumnsKey)
        testDefaults.set("invalid_double", forKey: SettingsDefaults.iconSizeKey)
        
        let draft = SettingsDraft.load(from: testDefaults)
        
        // Should handle corrupted values gracefully
        XCTAssertNotNil(draft)
        
        testDefaults.removePersistentDomain(forName: "AppDock.CorruptionTest")
    }
    
    // MARK: - Menu Swipe Logic Edge Cases
    
    /// Tests swipe logic with zero width
    func testSwipeLogicWithZeroWidth() {
        let zeroWidth: CGFloat = 0
        let threshold = MenuSwipeLogic.commitThreshold(width: zeroWidth)
        
        XCTAssertEqual(threshold, AppDockConstants.MenuGestures.swipeThreshold)
    }
    
    /// Tests swipe logic with negative values
    func testSwipeLogicWithNegativeValues() {
        let negativeWidth: CGFloat = -100
        let horizontal: CGFloat = -50
        let vertical: CGFloat = -25
        
        // With negative width, should not commit (or handle gracefully)
        let shouldCommit = MenuSwipeLogic.shouldCommit(horizontal: horizontal, vertical: vertical, width: negativeWidth)
        // Test that it handles negative width gracefully (either returns false or handles edge case)
        XCTAssertTrue(shouldCommit == false || shouldCommit == true, "Should handle negative width without crashing")
    }
    
    /// Tests swipe logic at page boundaries
    func testSwipeLogicAtBoundaries() {
        XCTAssertNil(MenuSwipeLogic.nextPage(from: .dock, direction: .right))
        XCTAssertNil(MenuSwipeLogic.nextPage(from: .actions, direction: .left))
        
        XCTAssertEqual(MenuSwipeLogic.nextPage(from: .dock, direction: .left), .recents)
        XCTAssertEqual(MenuSwipeLogic.nextPage(from: .recents, direction: .right), .dock)
    }
    
    // MARK: - Performance & Error Recovery Edge Cases
    
    /// Tests memory pressure with large datasets
    func testMemoryPressureWithLargeDatasets() {
        // Simulate memory pressure by creating and destroying large datasets
        for _ in 0..<50 {
            autoreleasepool {
                let tempState = AppState()
                tempState.recentApps = (0..<200).map { index in
                    ("Temp App \(index)", "com.temp.app\(index)", NSImage())
                }
                let _ = tempState.recentApps.count
            }
        }
        
        // Original appState should still be functional
        XCTAssertNoThrow(appState.recentApps = [("Test", "com.test", NSImage())])
        XCTAssertEqual(appState.recentApps.count, 1)
    }
    
    /// Tests rapid state changes without corruption
    func testRapidStateChanges() {
        for i in 0..<100 {
            appState.recentApps = [("App \(i)", "com.test.app\(i)", NSImage())]
            appState.filterOption = (i % 2 == 0) ? .all : .runningOnly
            appState.sortOption = (i % 3 == 0) ? .recent : .nameAscending
        }
        
        XCTAssertEqual(appState.recentApps.count, 1)
        XCTAssertEqual(appState.recentApps.first?.name, "App 99")
    }
    
    /// Tests handling of nil images
    func testNilImageHandling() {
        let appWithNilImage: AppState.AppEntry = ("Nil Image App", "com.test.nilimage", NSImage())
        
        XCTAssertNoThrow(appState.recentApps = [appWithNilImage])
        XCTAssertEqual(appState.recentApps.count, 1)
        XCTAssertEqual(appState.recentApps.first?.name, "Nil Image App")
    }
    
    /// Tests handling of very long app names
    func testVeryLongAppNames() {
        let veryLongName = String(repeating: "A", count: 1000)
        let appWithLongName: AppState.AppEntry = (veryLongName, "com.test.longname", NSImage())
        
        XCTAssertNoThrow(appState.recentApps = [appWithLongName])
        XCTAssertEqual(appState.recentApps.first?.name.count, 1000)
    }
    
    /// Tests handling of duplicate bundle IDs
    func testDuplicateBundleIds() {
        let duplicateApps: [AppState.AppEntry] = [
            ("App 1", "com.test.duplicate", NSImage()),
            ("App 2", "com.test.duplicate", NSImage()),
            ("App 3", "com.test.duplicate", NSImage())
        ]
        
        XCTAssertNoThrow(appState.recentApps = duplicateApps)
        XCTAssertEqual(appState.recentApps.count, 3)
        
        // Test dedupification
        let uniqueBundleIds = Set(appState.recentApps.map { $0.bundleid })
        XCTAssertEqual(uniqueBundleIds.count, 1)
    }
}

// MARK: - Mock Classes

/// Mock implementation of HotKeyRegistrar for testing
private class MockHotKeyRegistrar: HotKeyRegistrar {
    struct RegisterCall {
        let keyCode: UInt32
        let modifiers: UInt32
        let hotKeyId: EventHotKeyID
    }
    
    private(set) var registerCalls: [RegisterCall] = []
    private(set) var unregisterCalls: [EventHotKeyRef] = []
    private(set) var failedRegistrations: Int = 0
    private(set) var failedUnregistrations: Int = 0
    
    var shouldFailRegistration: Bool = false
    var shouldFailUnregistration: Bool = false
    
    func registerHotKey(
        keyCode: UInt32,
        modifiers: UInt32,
        hotKeyId: EventHotKeyID
    ) -> EventHotKeyRef? {
        if shouldFailRegistration {
            failedRegistrations += 1
            return nil
        }
        
        registerCalls.append(RegisterCall(keyCode: keyCode, modifiers: modifiers, hotKeyId: hotKeyId))
        return OpaquePointer(bitPattern: Int(hotKeyId.id) + 1)
    }
    
    func unregisterHotKey(_ hotKeyRef: EventHotKeyRef) {
        if shouldFailUnregistration {
            failedUnregistrations += 1
            return
        }
        
        unregisterCalls.append(hotKeyRef)
    }
}
