//
//  PerformanceUITests.swift
//  AppDockUITests
//

import XCTest

final class PerformanceUITests: UITestBase {
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
