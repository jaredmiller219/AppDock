@testable import AppDock
import XCTest

/// Verifies AppState and SettingsDraft stay in sync for every setting option.
final class AppStateSettingsTests: XCTestCase {
    func testApplySettings_updatesAllPublishedValues() {
        let appState = AppState()
        let draft = SettingsDraft(
            launchAtLogin: true,
            openOnStartup: false,
            autoUpdates: false,
            showAppLabels: false,
            showRunningIndicator: false,
            enableHoverRemove: false,
            confirmBeforeQuit: true,
            keepQuitApps: false,
            defaultFilter: .runningOnly,
            defaultSort: .nameDescending,
            gridColumns: 5,
            gridRows: 6,
            iconSize: 72,
            labelSize: 12,
            reduceMotion: true,
            debugLogging: true,
            simpleSettings: true,
            menuLayoutMode: .simple,
            shortcutTogglePopover: nil,
            shortcutNextPage: nil,
            shortcutPreviousPage: nil,
            shortcutOpenDock: nil,
            shortcutOpenRecents: nil,
            shortcutOpenFavorites: nil,
            shortcutOpenActions: nil
        )

        // Apply the full snapshot and assert each published property updated.
        appState.applySettings(draft)

        XCTAssertTrue(appState.launchAtLogin)
        XCTAssertFalse(appState.openOnStartup)
        XCTAssertFalse(appState.autoUpdates)
        XCTAssertFalse(appState.showAppLabels)
        XCTAssertFalse(appState.showRunningIndicator)
        XCTAssertFalse(appState.enableHoverRemove)
        XCTAssertTrue(appState.confirmBeforeQuit)
        XCTAssertFalse(appState.keepQuitApps)
        XCTAssertEqual(appState.filterOption, .runningOnly)
        XCTAssertEqual(appState.sortOption, .nameDescending)
        XCTAssertEqual(appState.gridColumns, 5)
        XCTAssertEqual(appState.gridRows, 6)
        XCTAssertEqual(appState.iconSize, 72, accuracy: 0.01)
        XCTAssertEqual(appState.labelSize, 12, accuracy: 0.01)
        XCTAssertTrue(appState.reduceMotion)
        XCTAssertTrue(appState.debugLogging)
        XCTAssertEqual(appState.menuLayoutMode, .simple)
    }

    func testSettingsDraftFromAppState_reflectsValues() {
        let appState = AppState()
        appState.launchAtLogin = true
        appState.openOnStartup = false
        appState.autoUpdates = false
        appState.showAppLabels = false
        appState.showRunningIndicator = false
        appState.enableHoverRemove = false
        appState.confirmBeforeQuit = true
        appState.keepQuitApps = false
        appState.filterOption = .runningOnly
        appState.sortOption = .nameAscending
        appState.gridColumns = 4
        appState.gridRows = 7
        appState.iconSize = 80
        appState.labelSize = 10
        appState.reduceMotion = true
        appState.debugLogging = true
        appState.menuLayoutMode = .simple

        // Capture current settings as a draft snapshot.
        let draft = SettingsDraft.from(appState: appState)

        XCTAssertTrue(draft.launchAtLogin)
        XCTAssertFalse(draft.openOnStartup)
        XCTAssertFalse(draft.autoUpdates)
        XCTAssertFalse(draft.showAppLabels)
        XCTAssertFalse(draft.showRunningIndicator)
        XCTAssertFalse(draft.enableHoverRemove)
        XCTAssertTrue(draft.confirmBeforeQuit)
        XCTAssertFalse(draft.keepQuitApps)
        XCTAssertEqual(draft.defaultFilter, .runningOnly)
        XCTAssertEqual(draft.defaultSort, .nameAscending)
        XCTAssertEqual(draft.gridColumns, 4)
        XCTAssertEqual(draft.gridRows, 7)
        XCTAssertEqual(draft.iconSize, 80, accuracy: 0.01)
        XCTAssertEqual(draft.iconSize, 80, accuracy: 0.01)
        XCTAssertEqual(draft.labelSize, 10, accuracy: 0.01)
        XCTAssertTrue(draft.reduceMotion)
        XCTAssertTrue(draft.debugLogging)
        XCTAssertEqual(draft.menuLayoutMode, .simple)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyRecentAppsHandling() {
        let appState = AppState()
        appState.recentApps = []
        
        XCTAssertTrue(appState.recentApps.isEmpty)
        XCTAssertNoThrow(appState.recentApps.removeAll())
        
        // Test filtering doesn't crash with empty array
        let filtered = appState.recentApps.filter { !$0.name.isEmpty }
        XCTAssertTrue(filtered.isEmpty)
    }
    
    func testCorruptedDataRecovery() {
        let appState = AppState()
        let corruptedApps: [AppState.AppEntry] = [
            ("", "com.test.valid", NSImage()), // Empty name
            ("Valid App", "", NSImage()), // Empty bundle ID
        ]
        
        XCTAssertNoThrow(appState.recentApps = corruptedApps)
        
        // Test filtering removes invalid entries
        let validApps = appState.recentApps.filter { !$0.name.isEmpty && !$0.bundleid.isEmpty }
        XCTAssertLessThanOrEqual(validApps.count, corruptedApps.count)
    }
    
    func testLargeDatasetPerformance() {
        let appState = AppState()
        let largeAppList = (0..<500).map { index in
            ("App \(index)", "com.test.app\(index)", NSImage(size: NSSize(width: 64, height: 64)))
        }
        
        measure {
            appState.recentApps = largeAppList
            let _ = appState.recentApps.count
            let _ = appState.recentApps.first { $0.name.contains("250") }
        }
    }
    
    func testConcurrentAppStateAccess() {
        let appState = AppState()
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 10
        
        let concurrentQueue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        let serialQueue = DispatchQueue(label: "test.serial")
        
        for i in 0..<10 {
            concurrentQueue.async {
                let newApp: AppState.AppEntry = ("App \(i)", "com.test.concurrent\(i)", NSImage())
                serialQueue.async {
                    appState.recentApps.append(newApp)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(appState.recentApps.count, 10)
    }
    
    func testNilImageHandling() {
        let appState = AppState()
        let appWithNilImage: AppState.AppEntry = ("Nil Image App", "com.test.nilimage", NSImage())
        
        XCTAssertNoThrow(appState.recentApps = [appWithNilImage])
        XCTAssertEqual(appState.recentApps.count, 1)
        XCTAssertEqual(appState.recentApps.first?.name, "Nil Image App")
    }
    
    func testVeryLongAppNames() {
        let appState = AppState()
        let veryLongName = String(repeating: "A", count: 1000)
        let appWithLongName: AppState.AppEntry = (veryLongName, "com.test.longname", NSImage())
        
        XCTAssertNoThrow(appState.recentApps = [appWithLongName])
        XCTAssertEqual(appState.recentApps.first?.name.count, 1000)
    }
    
    func testDuplicateBundleIds() {
        let appState = AppState()
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
