@testable import AppDock
import AppKit
import XCTest

/// Verifies the pure dock list builder used by DockView.
final class DockAppListTests: XCTestCase {
    private func makeEntry(name: String, bundleId: String) -> AppState.AppEntry {
        (name: name, bundleid: bundleId, icon: NSImage(size: NSSize(width: 1, height: 1)))
    }

    func testBuild_filtersRunningOnly() {
        let apps = [
            makeEntry(name: "A", bundleId: "com.running.a"),
            makeEntry(name: "B", bundleId: "com.stopped.b"),
            makeEntry(name: "C", bundleId: ""),
        ]
        let runningSet: Set<String> = ["com.running.a"]
        let result = DockAppList.build(
            apps: apps,
            filter: .runningOnly,
            sort: .recent,
            totalSlots: 3,
            isRunning: { runningSet.contains($0) }
        )

        XCTAssertEqual(result.count, 3, "Filtered list should still be padded to slot count.")
        XCTAssertEqual(result[0].bundleid, "com.running.a")
        XCTAssertTrue(result[1].bundleid.isEmpty, "Padding should fill remaining slots.")
    }

    func testBuild_sortsByNameAscending() {
        let apps = [
            makeEntry(name: "Zulu", bundleId: "z"),
            makeEntry(name: "Alpha", bundleId: "a"),
            makeEntry(name: "Echo", bundleId: "e"),
        ]
        let result = DockAppList.build(
            apps: apps,
            filter: .all,
            sort: .nameAscending,
            totalSlots: 3,
            isRunning: { _ in true }
        )

        XCTAssertEqual(result.map(\.name), ["Alpha", "Echo", "Zulu"])
    }

    func testBuild_sortsByNameDescending() {
        let apps = [
            makeEntry(name: "Bravo", bundleId: "b"),
            makeEntry(name: "Charlie", bundleId: "c"),
            makeEntry(name: "Alpha", bundleId: "a"),
        ]
        let result = DockAppList.build(
            apps: apps,
            filter: .all,
            sort: .nameDescending,
            totalSlots: 3,
            isRunning: { _ in true }
        )

        XCTAssertEqual(result.map(\.name), ["Charlie", "Bravo", "Alpha"])
    }

    func testBuild_padsToTotalSlots() {
        let apps = [
            makeEntry(name: "Solo", bundleId: "solo"),
        ]
        let result = DockAppList.build(
            apps: apps,
            filter: .all,
            sort: .recent,
            totalSlots: 4,
            isRunning: { _ in true }
        )

        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].bundleid, "solo")
        XCTAssertTrue(result[1].bundleid.isEmpty)
        XCTAssertTrue(result[2].bundleid.isEmpty)
        XCTAssertTrue(result[3].bundleid.isEmpty)
    }

    func testPadApps_skipsPaddingWhenSlotsFilled() {
        let apps = [
            makeEntry(name: "One", bundleId: "1"),
            makeEntry(name: "Two", bundleId: "2"),
        ]
        let result = DockAppList.padApps(apps, totalSlots: 1)

        XCTAssertEqual(result.count, 2, "List should not be truncated when totalSlots is smaller.")
    }
}
