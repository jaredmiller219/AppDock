import XCTest
@testable import AppDock

/// Verifies SettingsDefaults keys and restore behavior.
final class SettingsDefaultsTests: XCTestCase {
    private let suiteName = "AppDock.SettingsDefaultsTests"

    /// Creates a clean, isolated UserDefaults suite for testing.
    private func makeDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    /// Ensures the defaults dictionary matches the declared default values.
    func testDefaultsDictionary_matchesExpectedValues() {
        // Validate every key/value pair so defaults stay in sync with SettingsDefaults.
        let values = SettingsDefaults.defaultsDictionary()

        XCTAssertEqual(values[SettingsDefaults.launchAtLoginKey] as? Bool, SettingsDefaults.launchAtLoginDefault)
        XCTAssertEqual(values[SettingsDefaults.openOnStartupKey] as? Bool, SettingsDefaults.openOnStartupDefault)
        XCTAssertEqual(values[SettingsDefaults.autoUpdatesKey] as? Bool, SettingsDefaults.autoUpdatesDefault)
        XCTAssertEqual(values[SettingsDefaults.showAppLabelsKey] as? Bool, SettingsDefaults.showAppLabelsDefault)
        XCTAssertEqual(values[SettingsDefaults.showRunningIndicatorKey] as? Bool, SettingsDefaults.showRunningIndicatorDefault)
        XCTAssertEqual(values[SettingsDefaults.enableHoverRemoveKey] as? Bool, SettingsDefaults.enableHoverRemoveDefault)
        XCTAssertEqual(values[SettingsDefaults.confirmBeforeQuitKey] as? Bool, SettingsDefaults.confirmBeforeQuitDefault)
        XCTAssertEqual(values[SettingsDefaults.keepQuitAppsKey] as? Bool, SettingsDefaults.keepQuitAppsDefault)
        XCTAssertEqual(values[SettingsDefaults.defaultFilterKey] as? String, SettingsDefaults.defaultFilterDefault.rawValue)
        XCTAssertEqual(values[SettingsDefaults.defaultSortKey] as? String, SettingsDefaults.defaultSortDefault.rawValue)
        XCTAssertEqual(values[SettingsDefaults.gridColumnsKey] as? Int, SettingsDefaults.gridColumnsDefault)
        XCTAssertEqual(values[SettingsDefaults.gridRowsKey] as? Int, SettingsDefaults.gridRowsDefault)
        XCTAssertEqual(values[SettingsDefaults.iconSizeKey] as? Double, SettingsDefaults.iconSizeDefault)
        XCTAssertEqual(values[SettingsDefaults.labelSizeKey] as? Double, SettingsDefaults.labelSizeDefault)
        XCTAssertEqual(values[SettingsDefaults.reduceMotionKey] as? Bool, SettingsDefaults.reduceMotionDefault)
        XCTAssertEqual(values[SettingsDefaults.debugLoggingKey] as? Bool, SettingsDefaults.debugLoggingDefault)
        XCTAssertEqual(values[SettingsDefaults.menuPageKey] as? String, SettingsDefaults.menuPageDefault.rawValue)
    }

    /// Ensures restore writes the expected values into UserDefaults.
    func testRestoreWritesDefaultsToUserDefaults() {
        // Use an isolated suite so tests do not pollute real app settings.
        let defaults = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        SettingsDefaults.restore(in: defaults)

        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.launchAtLoginKey), SettingsDefaults.launchAtLoginDefault)
        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.openOnStartupKey), SettingsDefaults.openOnStartupDefault)
        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.autoUpdatesKey), SettingsDefaults.autoUpdatesDefault)
        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.showAppLabelsKey), SettingsDefaults.showAppLabelsDefault)
        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.showRunningIndicatorKey), SettingsDefaults.showRunningIndicatorDefault)
        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.enableHoverRemoveKey), SettingsDefaults.enableHoverRemoveDefault)
        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.confirmBeforeQuitKey), SettingsDefaults.confirmBeforeQuitDefault)
        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.keepQuitAppsKey), SettingsDefaults.keepQuitAppsDefault)
        XCTAssertEqual(defaults.string(forKey: SettingsDefaults.defaultFilterKey), SettingsDefaults.defaultFilterDefault.rawValue)
        XCTAssertEqual(defaults.string(forKey: SettingsDefaults.defaultSortKey), SettingsDefaults.defaultSortDefault.rawValue)
        XCTAssertEqual(defaults.integer(forKey: SettingsDefaults.gridColumnsKey), SettingsDefaults.gridColumnsDefault)
        XCTAssertEqual(defaults.integer(forKey: SettingsDefaults.gridRowsKey), SettingsDefaults.gridRowsDefault)
        XCTAssertEqual(defaults.double(forKey: SettingsDefaults.iconSizeKey), SettingsDefaults.iconSizeDefault, accuracy: 0.01)
        XCTAssertEqual(defaults.double(forKey: SettingsDefaults.labelSizeKey), SettingsDefaults.labelSizeDefault, accuracy: 0.01)
        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.reduceMotionKey), SettingsDefaults.reduceMotionDefault)
        XCTAssertEqual(defaults.bool(forKey: SettingsDefaults.debugLoggingKey), SettingsDefaults.debugLoggingDefault)
        XCTAssertEqual(defaults.string(forKey: SettingsDefaults.menuPageKey), SettingsDefaults.menuPageDefault.rawValue)
    }
}
