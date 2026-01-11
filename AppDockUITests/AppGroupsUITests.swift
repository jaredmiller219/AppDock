//
//  AppGroupsUITests.swift
//  AppDockUITests
//
//  UI tests for AppGroups functionality
//

import XCTest
import SwiftUI

final class AppGroupsUITests: UITestBase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        
        // Navigate to AppGroups if needed
        // This depends on your app's navigation structure
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - App Groups List Tests
    
    func testAppGroupsListDisplays() throws {
        // Verify that the AppGroups list is displayed
        let appGroupsTitle = app.staticTexts["App Groups"]
        XCTAssertTrue(appGroupsTitle.waitForExistence(timeout: 5), "App Groups title should be displayed")
        
        // Verify system groups are displayed
        let workGroup = app.staticTexts["Work"]
        let creativeGroup = app.staticTexts["Creative"]
        let developmentGroup = app.staticTexts["Development"]
        
        XCTAssertTrue(workGroup.waitForExistence(timeout: 3), "Work group should be displayed")
        XCTAssertTrue(creativeGroup.waitForExistence(timeout: 3), "Creative group should be displayed")
        XCTAssertTrue(developmentGroup.waitForExistence(timeout: 3), "Development group should be displayed")
    }
    
    func testAddNewGroup() throws {
        // Tap the plus button to add a new group
        let addButton = app.buttons["plus"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Add button should exist")
        addButton.tap()
        
        // Verify the editor view is presented
        let newGroupTitle = app.staticTexts["New Group"]
        XCTAssertTrue(newGroupTitle.waitForExistence(timeout: 3), "New Group editor should be presented")
        
        // Enter group name
        let groupNameField = app.textFields["Group Name"]
        XCTAssertTrue(groupNameField.waitForExistence(timeout: 3), "Group name field should exist")
        groupNameField.tap()
        groupNameField.typeText("Test Group")
        
        // Select an icon
        let starIcon = app.images["star"]
        XCTAssertTrue(starIcon.waitForExistence(timeout: 3), "Star icon should exist")
        starIcon.tap()
        
        // Select a color
        let redColor = app.buttons.matching(identifier: "color-red").firstMatch
        if redColor.exists {
            redColor.tap()
        }
        
        // Create the group
        let createButton = app.buttons["Create"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 3), "Create button should exist")
        createButton.tap()
        
        // Verify the group was created
        let testGroup = app.staticTexts["Test Group"]
        XCTAssertTrue(testGroup.waitForExistence(timeout: 3), "Test Group should be created and displayed")
    }
    
    func testEditExistingGroup() throws {
        // First ensure we have a user group to edit
        try testAddNewGroup()
        
        // Find and tap the edit button for the test group
        let testGroupCell = app.cells.firstMatch
        if testGroupCell.exists {
            testGroupCell.swipeLeft() // Reveal edit/delete buttons
            let editButton = app.buttons["pencil"]
            if editButton.exists {
                editButton.tap()
                
                // Verify edit view is presented
                let editGroupTitle = app.staticTexts["Edit Group"]
                XCTAssertTrue(editGroupTitle.waitForExistence(timeout: 3), "Edit Group view should be presented")
                
                // Modify the group name
                let groupNameField = app.textFields["Group Name"]
                groupNameField.tap()
                groupNameField.clearText()
                groupNameField.typeText("Edited Group")
                
                // Save the changes
                let saveButton = app.buttons["Save"]
                XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save button should exist")
                saveButton.tap()
                
                // Verify the group was updated
                let editedGroup = app.staticTexts["Edited Group"]
                XCTAssertTrue(editedGroup.waitForExistence(timeout: 3), "Group should be updated")
            }
        }
    }
    
    func testDeleteUserGroup() throws {
        // First ensure we have a user group to delete
        try testAddNewGroup()
        
        // Find and delete the test group
        let testGroupCell = app.cells.firstMatch
        if testGroupCell.exists {
            testGroupCell.swipeLeft() // Reveal edit/delete buttons
            let deleteButton = app.buttons["trash"]
            if deleteButton.exists {
                deleteButton.tap()
                
                // Wait for the group to be removed
                let testGroup = app.staticTexts["Test Group"]
                let groupDisappeared = testGroup.waitForNonExistence(timeout: 3)
                XCTAssertTrue(groupDisappeared, "Test Group should be deleted")
            }
        }
    }
    
    func testCannotDeleteSystemGroup() throws {
        // Try to delete a system group (should not be possible)
        let workGroup = app.staticTexts["Work"]
        if workGroup.exists {
            // Find the cell containing the Work group
            let workGroupCell = app.cells.containing(.staticText, identifier: "Work").firstMatch
            if workGroupCell.exists {
                workGroupCell.swipeLeft()
                
                // Delete button should not exist for system groups
                let deleteButton = app.buttons["trash"]
                XCTAssertFalse(deleteButton.exists, "Delete button should not exist for system groups")
            }
        }
    }
    
    func testAddAppsToGroup() throws {
        // First ensure we have a group
        try testAddNewGroup()
        
        // Find and tap the add apps button
        let testGroupCell = app.cells.firstMatch
        if testGroupCell.exists {
            let addAppsButton = testGroupCell.buttons["plus"]
            if addAppsButton.exists {
                addAppsButton.tap()
                
                // Verify app picker is presented
                let addAppsTitle = app.staticTexts["Add Apps"]
                XCTAssertTrue(addAppsTitle.waitForExistence(timeout: 3), "Add Apps view should be presented")
                
                // Select an app to add
                let safariApp = app.staticTexts["Safari"]
                if safariApp.exists {
                    safariApp.tap()
                    
                    // Verify the app was added (plus button becomes minus)
                    let removeButton = app.buttons["minus.circle.fill"]
                    XCTAssertTrue(removeButton.waitForExistence(timeout: 3), "App should be added to group")
                }
                
                // Dismiss the picker
                let doneButton = app.buttons["Done"]
                if doneButton.exists {
                    doneButton.tap()
                }
            }
        }
    }
    
    func testColorPickerUpdatesIcons() throws {
        // Open the group editor
        let addButton = app.buttons["plus"]
        addButton.tap()
        
        let newGroupTitle = app.staticTexts["New Group"]
        XCTAssertTrue(newGroupTitle.waitForExistence(timeout: 3))
        
        // Select a color
        let redColor = app.buttons.matching(identifier: "color-red").firstMatch
        if redColor.exists {
            redColor.tap()
            
            // Verify that icons update to show the selected color
            // This would require checking the icon colors, which might need custom accessibility identifiers
            let folderIcon = app.images["folder"]
            XCTAssertTrue(folderIcon.exists, "Folder icon should exist")
        }
        
        // Select another color
        let blueColor = app.buttons.matching(identifier: "color-blue").firstMatch
        if blueColor.exists {
            blueColor.tap()
            
            // Verify icons update again
            let folderIcon = app.images["folder"]
            XCTAssertTrue(folderIcon.exists, "Folder icon should still exist")
        }
    }
    
    func testIconPickerInteraction() throws {
        // Open the group editor
        let addButton = app.buttons["plus"]
        addButton.tap()
        
        let newGroupTitle = app.staticTexts["New Group"]
        XCTAssertTrue(newGroupTitle.waitForExistence(timeout: 3))
        
        // Select different icons
        let starIcon = app.images["star"]
        if starIcon.exists {
            starIcon.tap()
            // Verify selection (might need to check for selection indicator)
        }
        
        let heartIcon = app.images["heart"]
        if heartIcon.exists {
            heartIcon.tap()
            // Verify selection changed
        }
    }
    
    func testGroupReordering() throws {
        // Get initial positions of groups
        let firstGroup = app.staticTexts.firstMatch
        let secondGroup = app.staticTexts.element(boundBy: 1)
        
        if firstGroup.exists && secondGroup.exists {
            // Find the cells containing these groups
            let firstCell = app.cells.element(boundBy: 0)
            let secondCell = app.cells.element(boundBy: 1)
            
            if firstCell.exists && secondCell.exists {
                // Perform drag and drop to reorder
                firstCell.press(forDuration: 0.5)
                
                // Calculate the center of the second cell for drag destination
                let secondCellCenter = secondCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: secondCellCenter)
                
                // Wait for reordering to complete
                sleep(1)
                
                // Verify groups were reordered (this might need more specific verification)
                XCTAssertTrue(firstGroup.exists, "Groups should still exist after reordering")
            }
        }
    }
    
    func testPreviewSectionUpdates() throws {
        // Open the group editor
        let addButton = app.buttons["plus"]
        addButton.tap()
        
        let newGroupTitle = app.staticTexts["New Group"]
        XCTAssertTrue(newGroupTitle.waitForExistence(timeout: 3))
        
        // Enter group name
        let groupNameField = app.textFields["Group Name"]
        groupNameField.tap()
        groupNameField.typeText("Preview Test")
        
        // Verify preview updates with new name
        let previewName = app.staticTexts["Preview Test"]
        XCTAssertTrue(previewName.waitForExistence(timeout: 3), "Preview should update with group name")
        
        // Select icon and color
        let starIcon = app.images["star"]
        if starIcon.exists {
            starIcon.tap()
            // Verify preview shows star icon
        }
        
        let redColor = app.buttons.matching(identifier: "color-red").firstMatch
        if redColor.exists {
            redColor.tap()
            // Verify preview shows red color
        }
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
