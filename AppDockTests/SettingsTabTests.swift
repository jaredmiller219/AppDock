@testable import AppDock
import XCTest
import SwiftUI

final class SettingsTabTests: XCTestCase {
    func testAllCasesCountAndTitles() {
        XCTAssertEqual(SettingsTab.allCases.count, 7, "There should be seven settings tabs.")

        // Spot-check titles
        XCTAssertEqual(SettingsTab.general.title, "General")
        XCTAssertEqual(SettingsTab.layout.title, "Layout")
        XCTAssertEqual(SettingsTab.shortcuts.title, "Shortcuts")
    }

    func testSystemImagesExist() {
        // Ensure system image names are non-empty for the UI
        for tab in SettingsTab.allCases {
            XCTAssertFalse(tab.systemImage.isEmpty, "Settings tab \(tab) must provide a system image name")
        }
    }
}
