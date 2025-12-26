import XCTest
@testable import AppDock

/// Verifies SettingsDraft loading and persistence behavior.
final class SettingsDraftTests: XCTestCase {
    private let suiteName = "AppDock.SettingsDraftTests"

    private func makeDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    func testLoad_readsDefaultsValues() {
        // Seed test defaults to confirm SettingsDraft reads each value correctly.
        let defaults = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set(true, forKey: SettingsDefaults.launchAtLoginKey)
        defaults.set(false, forKey: SettingsDefaults.openOnStartupKey)
        defaults.set(AppFilterOption.runningOnly.rawValue, forKey: SettingsDefaults.defaultFilterKey)
        defaults.set(AppSortOption.nameDescending.rawValue, forKey: SettingsDefaults.defaultSortKey)
        defaults.set(5, forKey: SettingsDefaults.gridColumnsKey)
        defaults.set(6, forKey: SettingsDefaults.gridRowsKey)
        defaults.set(72.0, forKey: SettingsDefaults.iconSizeKey)
        defaults.set(12.0, forKey: SettingsDefaults.labelSizeKey)
        defaults.set(true, forKey: SettingsDefaults.reduceMotionKey)
        defaults.set(true, forKey: SettingsDefaults.debugLoggingKey)
        defaults.set(true, forKey: SettingsDefaults.simpleSettingsKey)
        defaults.set(MenuLayoutMode.simple.rawValue, forKey: SettingsDefaults.menuLayoutModeKey)

        let draft = SettingsDraft.load(from: defaults)

        XCTAssertTrue(draft.launchAtLogin)
        XCTAssertFalse(draft.openOnStartup)
        XCTAssertEqual(draft.defaultFilter, .runningOnly)
        XCTAssertEqual(draft.defaultSort, .nameDescending)
        XCTAssertEqual(draft.gridColumns, 5)
        XCTAssertEqual(draft.gridRows, 6)
        XCTAssertEqual(draft.iconSize, 72.0, accuracy: 0.01)
        XCTAssertEqual(draft.labelSize, 12.0, accuracy: 0.01)
        XCTAssertTrue(draft.reduceMotion)
        XCTAssertTrue(draft.debugLogging)
        XCTAssertTrue(draft.simpleSettings)
        XCTAssertEqual(draft.menuLayoutMode, .simple)
    }

    func testApply_writesValuesToDefaults() {
        // Verify that apply writes the full settings snapshot to UserDefaults.
        let defaults = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

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
            defaultSort: .nameAscending,
            gridColumns: 4,
            gridRows: 3,
            iconSize: 70,
            labelSize: 9,
            reduceMotion: true,
            debugLogging: true,
            simpleSettings: true,
            menuLayoutMode: .simple
        )

        draft.apply(to: defaults)

        XCTAssertTrue(defaults.bool(forKey: SettingsDefaults.launchAtLoginKey))
        XCTAssertFalse(defaults.bool(forKey: SettingsDefaults.openOnStartupKey))
        XCTAssertFalse(defaults.bool(forKey: SettingsDefaults.autoUpdatesKey))
        XCTAssertFalse(defaults.bool(forKey: SettingsDefaults.showAppLabelsKey))
        XCTAssertFalse(defaults.bool(forKey: SettingsDefaults.showRunningIndicatorKey))
        XCTAssertFalse(defaults.bool(forKey: SettingsDefaults.enableHoverRemoveKey))
        XCTAssertTrue(defaults.bool(forKey: SettingsDefaults.confirmBeforeQuitKey))
        XCTAssertFalse(defaults.bool(forKey: SettingsDefaults.keepQuitAppsKey))
        XCTAssertEqual(defaults.string(forKey: SettingsDefaults.defaultFilterKey), AppFilterOption.runningOnly.rawValue)
        XCTAssertEqual(defaults.string(forKey: SettingsDefaults.defaultSortKey), AppSortOption.nameAscending.rawValue)
        XCTAssertEqual(defaults.integer(forKey: SettingsDefaults.gridColumnsKey), 4)
        XCTAssertEqual(defaults.integer(forKey: SettingsDefaults.gridRowsKey), 3)
        XCTAssertEqual(defaults.double(forKey: SettingsDefaults.iconSizeKey), 70, accuracy: 0.01)
        XCTAssertEqual(defaults.double(forKey: SettingsDefaults.labelSizeKey), 9, accuracy: 0.01)
        XCTAssertTrue(defaults.bool(forKey: SettingsDefaults.reduceMotionKey))
        XCTAssertTrue(defaults.bool(forKey: SettingsDefaults.debugLoggingKey))
        XCTAssertTrue(defaults.bool(forKey: SettingsDefaults.simpleSettingsKey))
        XCTAssertEqual(defaults.string(forKey: SettingsDefaults.menuLayoutModeKey), MenuLayoutMode.simple.rawValue)
    }
}
