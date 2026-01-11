//
//  AppGroupsUITests.swift
//  AppDockUITests
//
//  UI tests for AppGroups functionality
//

import XCTest

final class AppGroupsUITests: UITestBase {
    
    // MARK: - Basic App Groups Tests
    
    @MainActor
    func testAppGroupsWindowOpens() throws {
        let app = launchAppForAppGroupsTests()
        
        let appGroupsWindow = app.windows["App Groups"]
        XCTAssertTrue(appGroupsWindow.waitForExistence(timeout: 4), "App Groups window should open")
        
        // The header contains the title and add button
        let header = appGroupsWindow.staticTexts["app-groups-header"]
        XCTAssertTrue(header.waitForExistence(timeout: 2), "App Groups header should exist")
        
        // Also check that the main add button exists
        let addButton = appGroupsWindow.buttons["app-groups-header"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2), "Add button should exist")
    }
    
    @MainActor
    func testSystemGroupsDisplay() throws {
        let app = launchAppForAppGroupsTests()
        
        let appGroupsWindow = app.windows["App Groups"]
        XCTAssertTrue(appGroupsWindow.waitForExistence(timeout: 4))
        
        // Wait for groups to load
        sleep(1)
        
        // Check for system groups by their names
        let workGroup = appGroupsWindow.staticTexts["Work"]
        let creativeGroup = appGroupsWindow.staticTexts["Creative"]
        let developmentGroup = appGroupsWindow.staticTexts["Development"]
        let entertainmentGroup = appGroupsWindow.staticTexts["Entertainment"]
        let utilitiesGroup = appGroupsWindow.staticTexts["Utilities"]
        
        XCTAssertTrue(workGroup.waitForExistence(timeout: 3), "Work group should be displayed")
        XCTAssertTrue(creativeGroup.waitForExistence(timeout: 3), "Creative group should be displayed")
        XCTAssertTrue(developmentGroup.waitForExistence(timeout: 3), "Development group should be displayed")
        XCTAssertTrue(entertainmentGroup.waitForExistence(timeout: 3), "Entertainment group should be displayed")
        XCTAssertTrue(utilitiesGroup.waitForExistence(timeout: 3), "Utilities group should be displayed")
    }
    
    // MARK: - Add Group Tests
    
    @MainActor
    func testAddNewGroup() throws {
        let app = launchAppForAppGroupsTests()
        
        let appGroupsWindow = app.windows["App Groups"]
        XCTAssertTrue(appGroupsWindow.waitForExistence(timeout: 4))
        
        // Wait for groups to load
        sleep(1)
        
        // Click the add button (it's in the header)
        let addButton = appGroupsWindow.buttons["app-groups-header"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Add button should exist")
        addButton.tap()
        
        // Wait for editor sheet to appear - give it more time
        sleep(3)
        
        // Try to find the editor by looking for "New Group" text (since that's the title for new groups)
        let newGroupTitle = appGroupsWindow.staticTexts["New Group"]
        let editGroupTitle = appGroupsWindow.staticTexts["Edit Group"]
        
        // Verify editor is open
        XCTAssertTrue(newGroupTitle.exists || editGroupTitle.exists, "Editor title should exist")
        
        let actualTitle = newGroupTitle.exists ? "New Group" : "Edit Group"
        
        // Enter group name
        let groupNameField = appGroupsWindow.textFields["group-name-field"]
        if groupNameField.waitForExistence(timeout: 3) {
            groupNameField.tap()
            groupNameField.typeText("Test Group")
        }
        
        // Select an icon
        let starIcon = appGroupsWindow.buttons["icon-star"]
        if starIcon.waitForExistence(timeout: 2) {
            starIcon.tap()
        }
        
        // Select a color (blue)
        let blueColor = appGroupsWindow.buttons.matching(NSPredicate(format: "identifier CONTAINS 'color-'")).firstMatch
        if blueColor.waitForExistence(timeout: 2) {
            blueColor.tap()
        }
        
        // Create the group
        let createButton = appGroupsWindow.buttons["create-button"]
        if createButton.waitForExistence(timeout: 3) {
            createButton.tap()
        }
        
        // Wait for editor to close
        sleep(1)
        
        // Verify the group was created by looking for the name
        let testGroup = appGroupsWindow.staticTexts["Test Group"]
        XCTAssertTrue(testGroup.waitForExistence(timeout: 3), "Test Group should be created and displayed")
    }
    
    // MARK: - Edit Group Tests
    
    @MainActor
    func testEditExistingGroup() throws {
        // First create a group to edit
        try testAddNewGroup()
        
        let app = XCUIApplication()
        let appGroupsWindow = app.windows["App Groups"]
        
        // Wait for window to be ready
        XCTAssertTrue(appGroupsWindow.waitForExistence(timeout: 4))
        sleep(1)
        
        // Find and click the edit button for the test group
        // We need to find the group row first, then the edit button within it
        let groupRows = appGroupsWindow.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'group-row-'"))
        
        if groupRows.count > 0 {
            // Find the test group row (should be the last one we created)
            let testGroupRow = groupRows.element(boundBy: groupRows.count - 1)
            
            let editButton = testGroupRow.buttons.matching(NSPredicate(format: "identifier ENDSWITH '-edit-group'")).firstMatch
            if editButton.waitForExistence(timeout: 3) {
                editButton.tap()
                
                // Wait for editor to open
                sleep(1)
                
                // Verify edit view is presented
                let editorTitle = appGroupsWindow.staticTexts["editor-title"]
                XCTAssertTrue(editorTitle.waitForExistence(timeout: 3), "Edit Group view should be presented")
                
                // Modify the group name
                let groupNameField = appGroupsWindow.textFields["group-name-field"]
                groupNameField.tap()
                groupNameField.clearAndType(text: "Edited Group")
                
                // Save the changes
                let saveButton = appGroupsWindow.buttons["save-button"]
                XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save button should exist")
                saveButton.tap()
                
                // Wait for editor to close
                sleep(1)
                
                // Verify the group was updated
                let editedGroup = appGroupsWindow.staticTexts["Edited Group"]
                XCTAssertTrue(editedGroup.waitForExistence(timeout: 3), "Group should be updated")
            }
        }
    }
    
    // MARK: - Delete Group Tests
    
    @MainActor
    func testDeleteUserGroup() throws {
        // First create a group to delete
        try testAddNewGroup()
        
        let app = XCUIApplication()
        let appGroupsWindow = app.windows["App Groups"]
        
        // Wait for window to be ready
        XCTAssertTrue(appGroupsWindow.waitForExistence(timeout: 4))
        sleep(1)
        
        // Find the test group row (should be the last one we created)
        let groupRows = appGroupsWindow.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'group-row-'"))
        
        if groupRows.count > 0 {
            let testGroupRow = groupRows.element(boundBy: groupRows.count - 1)
            
            let deleteButton = testGroupRow.buttons.matching(NSPredicate(format: "identifier ENDSWITH '-delete-group'")).firstMatch
            if deleteButton.waitForExistence(timeout: 3) {
                deleteButton.tap()
                
                // Wait for the group to be removed
                sleep(1)
                
                // Verify the group is gone (this is tricky without knowing the exact UUID)
                // We'll check that the number of groups decreased
                let newGroupRows = appGroupsWindow.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'group-row-'"))
                XCTAssertTrue(newGroupRows.count < groupRows.count, "Group count should decrease after deletion")
            }
        }
    }
    
    @MainActor
    func testSystemGroupsCannotBeDeleted() throws {
        let app = launchAppForAppGroupsTests()
        
        let appGroupsWindow = app.windows["App Groups"]
        XCTAssertTrue(appGroupsWindow.waitForExistence(timeout: 4))
        
        // Wait for groups to load
        sleep(1)
        
        // Find the Work group (it's a system group)
        let workGroup = appGroupsWindow.staticTexts["Work"]
        if workGroup.waitForExistence(timeout: 3) {
            // Find the Work group row
            let groupRows = appGroupsWindow.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'group-row-'"))
            
            for i in 0..<groupRows.count {
                let row = groupRows.element(boundBy: i)
                let groupName = row.staticTexts.matching(NSPredicate(format: "identifier ENDSWITH '-Work'")).firstMatch
                
                if groupName.exists {
                    // Check that delete button doesn't exist for system groups
                    let deleteButton = row.buttons.matching(NSPredicate(format: "identifier ENDSWITH '-delete-group'")).firstMatch
                    XCTAssertFalse(deleteButton.exists, "Delete button should not exist for system groups")
                    break
                }
            }
        }
    }
    
    // MARK: - Add Apps to Group Tests
    
    @MainActor
    func testAddAppsToGroup() throws {
        let app = launchAppForAppGroupsTests()
        
        let appGroupsWindow = app.windows["App Groups"]
        XCTAssertTrue(appGroupsWindow.waitForExistence(timeout: 4))
        
        // Wait for groups to load
        sleep(1)
        
        // Find the Work group and click its add apps button
        let groupRows = appGroupsWindow.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'group-row-'"))
        
        for i in 0..<groupRows.count {
            let row = groupRows.element(boundBy: i)
            let groupName = row.staticTexts.matching(NSPredicate(format: "identifier ENDSWITH '-Work'")).firstMatch
            
            if groupName.exists {
                let addAppsButton = row.buttons.matching(NSPredicate(format: "identifier ENDSWITH '-add-apps'")).firstMatch
                if addAppsButton.waitForExistence(timeout: 3) {
                    addAppsButton.tap()
                    
                    // Wait for app picker to appear
                    sleep(1)
                    
                    // Verify app picker is presented
                    let addAppsTitle = appGroupsWindow.staticTexts["add-apps-title"]
                    XCTAssertTrue(addAppsTitle.waitForExistence(timeout: 3), "Add Apps view should be presented")
                    
                    // Select Safari to add
                    let safariApp = appGroupsWindow.buttons["app-toggle-com.apple.Safari"]
                    if safariApp.waitForExistence(timeout: 3) {
                        safariApp.tap()
                        
                        // Verify the app was added (button should now show minus)
                        sleep(1)
                        let removeButton = appGroupsWindow.buttons["app-toggle-com.apple.Safari"]
                        XCTAssertTrue(removeButton.waitForExistence(timeout: 3), "App should be added to group")
                    }
                    
                    // Dismiss the picker
                    let doneButton = appGroupsWindow.buttons["done-button"]
                    if doneButton.waitForExistence(timeout: 3) {
                        doneButton.tap()
                    }
                    
                    // Wait for picker to close
                    sleep(1)
                }
                break
            }
        }
    }
    
    // MARK: - Icon and Color Picker Tests
    
    @MainActor
    func testIconPickerInteraction() throws {
        let app = launchAppForAppGroupsTests()
        
        let appGroupsWindow = app.windows["App Groups"]
        XCTAssertTrue(appGroupsWindow.waitForExistence(timeout: 4))
        
        // Open the group editor
        let addButton = appGroupsWindow.buttons["app-groups-header"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        addButton.tap()
        
        // Wait for editor to open
        sleep(3)
        
        // Verify editor is open
        let newGroupTitle = appGroupsWindow.staticTexts["New Group"]
        let editGroupTitle = appGroupsWindow.staticTexts["Edit Group"]
        XCTAssertTrue(newGroupTitle.exists || editGroupTitle.exists, "Editor should be open")
        
        // Test selecting different icons - try to find them by their SF Symbol names
        let starIcon = appGroupsWindow.images["star"]
        if starIcon.waitForExistence(timeout: 3) {
            starIcon.tap()
            usleep(500_000) // 0.5 seconds in microseconds
        }
        
        let heartIcon = appGroupsWindow.images["heart"]
        if heartIcon.waitForExistence(timeout: 3) {
            heartIcon.tap()
            usleep(500_000) // 0.5 seconds in microseconds
        }
        
        let folderIcon = appGroupsWindow.images["folder"]
        if folderIcon.waitForExistence(timeout: 3) {
            folderIcon.tap()
            usleep(500_000) // 0.5 seconds in microseconds
        }
        
        // Cancel the editor
        let cancelButton = appGroupsWindow.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))
        cancelButton.tap()
    }
    
    @MainActor
    func testColorPickerInteraction() throws {
        let app = launchAppForAppGroupsTests()
        
        let appGroupsWindow = app.windows["App Groups"]
        XCTAssertTrue(appGroupsWindow.waitForExistence(timeout: 4))
        
        // Open the group editor
        let addButton = appGroupsWindow.buttons["app-groups-header"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        addButton.tap()
        
        // Wait for editor to open
        sleep(3)
        
        // Verify editor is open
        let newGroupTitle = appGroupsWindow.staticTexts["New Group"]
        let editGroupTitle = appGroupsWindow.staticTexts["Edit Group"]
        XCTAssertTrue(newGroupTitle.exists || editGroupTitle.exists, "Editor should be open")
        
        // Test selecting different colors - look for color buttons by their accessibility identifiers
        let colorButtons = appGroupsWindow.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'color-'"))
        
        if colorButtons.count > 0 {
            // Try first few colors
            for i in 0..<Swift.min(3, colorButtons.count) {
                let colorButton = colorButtons.element(boundBy: i)
                if colorButton.waitForExistence(timeout: 2) {
                    colorButton.tap()
                    usleep(500_000) // 0.5 seconds in microseconds
                }
            }
        }
        
        // Cancel the editor
        let cancelButton = appGroupsWindow.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))
        cancelButton.tap()
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearAndType(text: String) {
        guard let stringValue = self.value as? String else {
            self.typeText(text)
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
