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
        XCTAssertEqual(draft.labelSize, 10, accuracy: 0.01)
        XCTAssertTrue(draft.reduceMotion)
        XCTAssertTrue(draft.debugLogging)
        XCTAssertEqual(draft.menuLayoutMode, .simple)
    }
}
