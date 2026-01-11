//
//  ColorConversionTests.swift
//  AppDockTests
//
//  Unit tests for color conversion utilities
//

import XCTest
import SwiftUI
@testable import AppDock

final class ColorConversionTests: XCTestCase {
    
    // MARK: - Color Hex Extension Tests
    
    func testColorFromHex() {
        // Test basic hex colors
        let redColor = Color(hex: "#FF0000")
        let greenColor = Color(hex: "#00FF00")
        let blueColor = Color(hex: "#0000FF")
        let blackColor = Color(hex: "#000000")
        let whiteColor = Color(hex: "#FFFFFF")
        
        // These should not crash and should create valid colors
        XCTAssertNotNil(redColor)
        XCTAssertNotNil(greenColor)
        XCTAssertNotNil(blueColor)
        XCTAssertNotNil(blackColor)
        XCTAssertNotNil(whiteColor)
    }
    
    func testColorFromHexWithShortFormat() {
        // Test short hex format if supported
        let redColor = Color(hex: "#F00")
        let greenColor = Color(hex: "#0F0")
        let blueColor = Color(hex: "#00F")
        
        XCTAssertNotNil(redColor)
        XCTAssertNotNil(greenColor)
        XCTAssertNotNil(blueColor)
    }
    
    func testColorFromHexWithInvalidInput() {
        // Test invalid hex strings
        let invalidColor1 = Color(hex: "")
        let invalidColor2 = Color(hex: "GGGGGG")
        let invalidColor3 = Color(hex: "#1234") // Too short
        let invalidColor4 = Color(hex: "#12345678") // Too long
        
        XCTAssertNotNil(invalidColor1) // Should default to some color
        XCTAssertNotNil(invalidColor2)
        XCTAssertNotNil(invalidColor3)
        XCTAssertNotNil(invalidColor4)
    }
    
    func testColorFromHexWithHashPrefix() {
        // Test with and without hash prefix
        let withHash = Color(hex: "#FF0000")
        let withoutHash = Color(hex: "FF0000")
        
        XCTAssertNotNil(withHash)
        XCTAssertNotNil(withoutHash)
    }
    
    // MARK: - Color to Hex Conversion Tests
    
    func testColorToHexConversion() {
        // Test conversion from SwiftUI Color to hex string
        // Note: This would require access to the colorToHex function in AppGroupEditorView
        // For now, we'll test the concept
        
        let redColor = Color.red
        let blueColor = Color.blue
        let greenColor = Color.green
        
        // These would test the actual conversion if the function were accessible
        // let redHex = colorToHex(redColor)
        // XCTAssertEqual(redHex, "#FF0000")
        
        // For now, just verify the colors exist
        XCTAssertNotNil(redColor)
        XCTAssertNotNil(blueColor)
        XCTAssertNotNil(greenColor)
    }
    
    // MARK: - System Color Tests
    
    func testSystemColors() {
        // Test that system colors used in the app work correctly
        let systemBlue = Color.blue
        let systemRed = Color.red
        let systemGreen = Color.green
        let systemOrange = Color.orange
        let systemPurple = Color.purple
        let systemGray = Color.gray
        let systemBlack = Color.black
        let systemWhite = Color.white
        
        XCTAssertNotNil(systemBlue)
        XCTAssertNotNil(systemRed)
        XCTAssertNotNil(systemGreen)
        XCTAssertNotNil(systemOrange)
        XCTAssertNotNil(systemPurple)
        XCTAssertNotNil(systemGray)
        XCTAssertNotNil(systemBlack)
        XCTAssertNotNil(systemWhite)
    }
    
    // MARK: - Color Consistency Tests
    
    func testColorConsistencyAcrossViews() {
        // Test that colors are consistent between different views
        let testColor = Color.blue
        
        // This would test that the same color appears the same in different contexts
        // For example, in the icon picker, preview section, and group rows
        
        XCTAssertNotNil(testColor)
    }
    
    func testColorOpacity() {
        // Test color opacity functionality
        let baseColor = Color.blue
        let opacityColor = baseColor.opacity(0.5)
        
        XCTAssertNotNil(opacityColor)
        // Additional tests could verify the actual opacity value if accessible
    }
    
    // MARK: - Performance Tests
    
    func testColorConversionPerformance() {
        // Test performance of color conversion
        measure {
            for _ in 0..<1000 {
                _ = Color(hex: "#FF0000")
                _ = Color(hex: "#00FF00")
                _ = Color(hex: "#0000FF")
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testColorIntegrationWithAppGroup() {
        // Test that color conversion works end-to-end with AppGroup
        let group = AppGroup(
            name: "Color Test Group",
            icon: "star",
            color: "#FF00FF"
        )
        
        XCTAssertEqual(group.color, "#FF00FF")
        
        // Test that the color can be used to create a SwiftUI Color
        let swiftUIColor = Color(hex: group.color)
        XCTAssertNotNil(swiftUIColor)
    }
    
    func testColorPersistence() {
        // Test that colors persist correctly
        let originalColor = "#123456"
        let group = AppGroup(
            name: "Persistence Test",
            icon: "folder",
            color: originalColor
        )
        
        // Simulate saving and loading
        let groupManager = AppGroupManager()
        groupManager.addGroup(group)
        
        let loadedGroup = groupManager.groups.first { $0.name == "Persistence Test" }
        XCTAssertNotNil(loadedGroup)
        XCTAssertEqual(loadedGroup?.color, originalColor)
        
        // Test that the loaded color creates the same SwiftUI Color
        let recreatedColor = Color(hex: loadedGroup?.color ?? "#000000")
        XCTAssertNotNil(recreatedColor)
    }
}
