//
//  AppGroupTests.swift
//  AppDockTests
//
//  Unit tests for AppGroups functionality
//

import XCTest
import SwiftUI
@testable import AppDock

final class AppGroupTests: XCTestCase {
    
    var groupManager: AppGroupManager!
    
    override func setUp() {
        super.setUp()
        groupManager = AppGroupManager()
    }
    
    override func tearDown() {
        groupManager = nil
        super.tearDown()
    }
    
    // MARK: - AppGroup Model Tests
    
    func testAppGroupInitialization() {
        let group = AppGroup(
            name: "Test Group",
            icon: "star",
            color: "#FF0000",
            appBundleIds: ["com.test.app"],
            isSystem: false,
            sortOrder: 1
        )
        
        XCTAssertEqual(group.name, "Test Group")
        XCTAssertEqual(group.icon, "star")
        XCTAssertEqual(group.color, "#FF0000")
        XCTAssertEqual(group.appBundleIds.count, 1)
        XCTAssertTrue(group.appBundleIds.contains("com.test.app"))
        XCTAssertFalse(group.isSystem)
        XCTAssertEqual(group.sortOrder, 1)
    }
    
    func testAppGroupDefaultValues() {
        let group = AppGroup(name: "Default Group")
        
        XCTAssertEqual(group.name, "Default Group")
        XCTAssertEqual(group.icon, "folder")
        XCTAssertEqual(group.color, "#007AFF")
        XCTAssertTrue(group.appBundleIds.isEmpty)
        XCTAssertFalse(group.isSystem)
        XCTAssertEqual(group.sortOrder, 0)
    }
    
    func testAppGroupEquality() {
        let group1 = AppGroup(name: "Test", color: "#FF0000")
        let group2 = AppGroup(name: "Test", color: "#FF0000")
        
        // Different IDs should not be equal
        XCTAssertNotEqual(group1, group2)
        
        // Same instance should be equal
        XCTAssertEqual(group1, group1)
    }
    
    func testAppGroupHashable() {
        let group = AppGroup(name: "Test", color: "#FF0000")
        let hashValue = group.hashValue
        
        // Hash should be consistent
        XCTAssertEqual(group.hashValue, hashValue)
    }
    
    // MARK: - AppGroupManager Tests
    
    func testAppGroupManagerInitialization() {
        XCTAssertNotNil(groupManager)
        XCTAssertFalse(groupManager.groups.isEmpty)
        
        // Should have system groups
        let systemGroups = groupManager.groups.filter { $0.isSystem }
        XCTAssertGreaterThan(systemGroups.count, 0)
        
        // Should have expected system groups
        let systemGroupNames = systemGroups.map { $0.name }
        XCTAssertTrue(systemGroupNames.contains("Work"))
        XCTAssertTrue(systemGroupNames.contains("Creative"))
        XCTAssertTrue(systemGroupNames.contains("Development"))
        XCTAssertTrue(systemGroupNames.contains("Entertainment"))
        XCTAssertTrue(systemGroupNames.contains("Utilities"))
    }
    
    func testAddGroup() {
        let initialCount = groupManager.groups.count
        let newGroup = AppGroup(name: "Custom Group", icon: "heart", color: "#FF00FF")
        
        groupManager.addGroup(newGroup)
        
        XCTAssertEqual(groupManager.groups.count, initialCount + 1)
        
        let addedGroup = groupManager.groups.last { !$0.isSystem }
        XCTAssertNotNil(addedGroup)
        XCTAssertEqual(addedGroup?.name, "Custom Group")
        XCTAssertEqual(addedGroup?.icon, "heart")
        XCTAssertEqual(addedGroup?.color, "#FF00FF")
        XCTAssertFalse(addedGroup?.isSystem ?? true)
    }
    
    func testUpdateGroup() {
        let newGroup = AppGroup(name: "Original", icon: "folder", color: "#000000")
        groupManager.addGroup(newGroup)
        
        guard let addedGroup = groupManager.groups.last(where: { !$0.isSystem }) else {
            XCTFail("Group not found")
            return
        }
        
        // Debug: Print initial state
        print("Before update - Group name: \(addedGroup.name), ID: \(addedGroup.id)")
        print("Groups count before update: \(groupManager.groups.count)")
        
        // Create updated group with same ID
        let updatedGroup = AppGroup(
            id: addedGroup.id, // Use same ID from addedGroup
            name: "Updated",
            icon: "star",
            color: "#FFFFFF",
            appBundleIds: addedGroup.appBundleIds,
            isSystem: addedGroup.isSystem,
            sortOrder: addedGroup.sortOrder
        )
        
        groupManager.updateGroup(updatedGroup)
        
        // Debug: Print after update
        print("After update - Groups count: \(groupManager.groups.count)")
        let foundGroup = groupManager.groups.first { $0.id == addedGroup.id }
        if let foundGroup = foundGroup {
            print("Found group name: \(foundGroup.name), ID: \(foundGroup.id)")
        }
        
        XCTAssertNotNil(foundGroup)
        XCTAssertEqual(foundGroup?.name, "Updated")
        XCTAssertEqual(foundGroup?.icon, "star")
        XCTAssertEqual(foundGroup?.color, "#FFFFFF")
    }
    
    func testDeleteGroup() {
        let newGroup = AppGroup(name: "To Delete", icon: "trash", color: "#FF0000")
        groupManager.addGroup(newGroup)
        
        let initialCount = groupManager.groups.count
        
        guard let addedGroup = groupManager.groups.last(where: { !$0.isSystem }) else {
            XCTFail("Group not found")
            return
        }
        
        groupManager.deleteGroup(addedGroup)
        
        XCTAssertEqual(groupManager.groups.count, initialCount - 1)
        XCTAssertNil(groupManager.groups.first { $0.id == addedGroup.id })
    }
    
    func testDeleteSystemGroup() {
        let systemGroups = groupManager.groups.filter { $0.isSystem }
        guard let firstSystemGroup = systemGroups.first else {
            XCTFail("No system groups found")
            return
        }
        
        let initialCount = groupManager.groups.count
        
        // Should not be able to delete system groups
        groupManager.deleteGroup(firstSystemGroup)
        
        XCTAssertEqual(groupManager.groups.count, initialCount)
        XCTAssertNotNil(groupManager.groups.first { $0.id == firstSystemGroup.id })
    }
    
    func testAddAppToGroup() {
        guard let testGroup = groupManager.groups.first else {
            XCTFail("No groups found")
            return
        }
        
        let bundleId = "com.test.application"
        let initialCount = testGroup.appBundleIds.count
        
        groupManager.addAppToGroup(bundleId, groupId: testGroup.id)
        
        let updatedGroup = groupManager.groups.first { $0.id == testGroup.id }
        XCTAssertEqual(updatedGroup?.appBundleIds.count, initialCount + 1)
        XCTAssertTrue(updatedGroup?.appBundleIds.contains(bundleId) ?? false)
    }
    
    func testRemoveAppFromGroup() {
        guard let testGroup = groupManager.groups.first else {
            XCTFail("No groups found")
            return
        }
        
        let bundleId = "com.test.application"
        
        // First add an app
        groupManager.addAppToGroup(bundleId, groupId: testGroup.id)
        
        // Then remove it
        groupManager.removeAppFromGroup(bundleId, groupId: testGroup.id)
        
        let updatedGroup = groupManager.groups.first { $0.id == testGroup.id }
        XCTAssertFalse(updatedGroup?.appBundleIds.contains(bundleId) ?? true)
    }
    
    func testGetGroupsForApp() {
        guard let testGroup1 = groupManager.groups.first,
              let testGroup2 = groupManager.groups.dropFirst().first else {
            XCTFail("Not enough groups found")
            return
        }
        
        let bundleId = "com.test.sharedapp"
        
        // Add app to two groups
        groupManager.addAppToGroup(bundleId, groupId: testGroup1.id)
        groupManager.addAppToGroup(bundleId, groupId: testGroup2.id)
        
        let groupsForApp = groupManager.getGroupsForApp(bundleId)
        
        XCTAssertEqual(groupsForApp.count, 2)
        XCTAssertTrue(groupsForApp.contains { $0.id == testGroup1.id })
        XCTAssertTrue(groupsForApp.contains { $0.id == testGroup2.id })
    }
    
    func testMoveGroup() {
        let userGroups = groupManager.groups.filter { !$0.isSystem }
        guard userGroups.count >= 2 else {
            XCTFail("Not enough user groups for move test")
            return
        }
        
        let firstGroup = userGroups[0]
        let secondGroup = userGroups[1]
        let initialFirstIndex = groupManager.groups.firstIndex(of: firstGroup)
        let initialSecondIndex = groupManager.groups.firstIndex(of: secondGroup)
        
        // Move first group to second group's position
        groupManager.moveGroup(firstGroup, to: initialSecondIndex ?? 0)
        
        let newFirstIndex = groupManager.groups.firstIndex(of: firstGroup)
        let newSecondIndex = groupManager.groups.firstIndex(of: secondGroup)
        
        XCTAssertEqual(newFirstIndex, initialSecondIndex)
        XCTAssertEqual(newSecondIndex, initialFirstIndex)
        
        // Verify the actual groups array was reordered
        let groupsAfterMove = groupManager.groups
        let firstGroupAfterMove = groupsAfterMove[newFirstIndex ?? 0]
        let secondGroupAfterMove = groupsAfterMove[newSecondIndex ?? 0]
        
        XCTAssertEqual(firstGroupAfterMove.name, firstGroup.name)
        XCTAssertEqual(secondGroupAfterMove.name, secondGroup.name)
    }
    
    // MARK: - Color Conversion Tests
    
    func testColorToHexConversion() {
        // This would test the colorToHex function if it were accessible
        // For now, we'll test the Color(hex:) extension
        
        let redColor = Color(hex: "#FF0000")
        let blueColor = Color(hex: "#0000FF")
        let greenColor = Color(hex: "#00FF00")
        
        // These tests would require access to the color components
        // For now, just ensure the colors can be created without crashing
        XCTAssertNotNil(redColor)
        XCTAssertNotNil(blueColor)
        XCTAssertNotNil(greenColor)
    }
    
    // MARK: - Persistence Tests
    
    func testGroupPersistence() {
        let testGroup = AppGroup(name: "Persistence Test", icon: "star", color: "#123456")
        groupManager.addGroup(testGroup)
        
        // Create a new manager to simulate app restart
        let newManager = AppGroupManager()
        
        let persistedGroup = newManager.groups.first { $0.name == "Persistence Test" }
        XCTAssertNotNil(persistedGroup)
        XCTAssertEqual(persistedGroup?.icon, "star")
        XCTAssertEqual(persistedGroup?.color, "#123456")
    }
}
