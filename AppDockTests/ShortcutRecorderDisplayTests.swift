@testable import AppDock
import XCTest

final class ShortcutRecorderDisplayTests: XCTestCase {
    /// Test that ShortcutRecorderField displays "Recording..." when in editing mode.
    func testRecorderFieldDisplay_showsRecordingWhenEditing() {
        let field = ShortcutRecorderField()
        
        // Simulate entering editing mode by calling becomeFirstResponder
        // This would normally be triggered by user clicking the field
        _ = field.becomeFirstResponder()
        
        // Verify the display text shows "Recording..."
        XCTAssertEqual(field.stringValue, "Recording...", 
                      "Field should display 'Recording...' when actively recording")
    }
    
    /// Test that ShortcutRecorderField displays "Record Shortcut" when not editing (empty).
    func testRecorderFieldDisplay_showsRecordShortcutWhenEmpty() {
        let field = ShortcutRecorderField()
        field.updateDisplay(with: nil, isEditing: false)
        
        XCTAssertEqual(field.stringValue, "Record Shortcut",
                      "Field should display 'Record Shortcut' when no shortcut is set")
    }
    
    /// Test that ShortcutRecorderField displays formatted shortcut when set.
    func testRecorderFieldDisplay_showsFormattedShortcutWhenSet() {
        let field = ShortcutRecorderField()
        let shortcut = ShortcutDefinition(keyCode: 12, modifiers: [.command, .shift])
        
        field.updateDisplay(with: shortcut, isEditing: false)
        
        // Should display the formatted shortcut (e.g., "⇧⌘Q")
        let expectedFormat = ShortcutFormatter.string(for: shortcut)
        XCTAssertEqual(field.stringValue, expectedFormat,
                      "Field should display formatted shortcut")
    }
    
    /// Test that editing state changes trigger display updates.
    func testRecorderFieldDisplay_updatesOnEditingStateChange() {
        let field = ShortcutRecorderField()
        var editingStateChanged = false
        
        field.onEditingStateChange = { _ in
            editingStateChanged = true
        }
        
        // Simulate focus (entering editing mode)
        _ = field.becomeFirstResponder()
        
        XCTAssertTrue(editingStateChanged, "Editing state change callback should be triggered")
        XCTAssertEqual(field.stringValue, "Recording...",
                      "Display should update to 'Recording...' during editing")
    }
    
    /// Test that exiting editing mode preserves the recorded shortcut display.
    func testRecorderFieldDisplay_preservesShortcutAfterEditing() {
        let field = ShortcutRecorderField()
        let shortcut = ShortcutDefinition(keyCode: 36, modifiers: [.control, .option])
        
        // Simulate recording and exiting
        field.updateDisplay(with: shortcut, isEditing: true)
        XCTAssertEqual(field.stringValue, "Recording...", "Should show Recording during edit")
        
        field.updateDisplay(with: shortcut, isEditing: false)
        let expectedFormat = ShortcutFormatter.string(for: shortcut)
        XCTAssertEqual(field.stringValue, expectedFormat,
                      "Should display recorded shortcut after editing completes")
    }
    
    /// Test that live preview shows modifiers as they're pressed.
    func testRecorderFieldDisplay_showsModifiersLivePreview() {
        let field = ShortcutRecorderField()
        
        // Simulate modifiers being pressed
        let modifiers: NSEvent.ModifierFlags = [.command, .option]
        let previewText = field.formatModifiers(modifiers)
        
        XCTAssertEqual(previewText, "⌥⌘", 
                      "Should display modifier symbols as they're pressed")
        XCTAssertTrue(previewText.contains("⌘"), "Should contain command symbol")
        XCTAssertTrue(previewText.contains("⌥"), "Should contain option symbol")
    }
    
    /// Test that formatModifiers returns just "Recording..." when no modifiers are pressed.
    func testRecorderFieldDisplay_showsRecordingWhenNoModifiers() {
        let field = ShortcutRecorderField()
        
        let modifiers: NSEvent.ModifierFlags = []
        let previewText = field.formatModifiers(modifiers)
        
        XCTAssertEqual(previewText, "Recording...",
                      "Should show Recording when no modifiers are pressed")
    }
    
    /// Test that live preview shows complete shortcut when main key is pressed.
    func testRecorderFieldDisplay_showsCompleteShortcutLivePreview() {
		_ = ShortcutRecorderField()
        let shortcut = ShortcutDefinition(keyCode: 12, modifiers: [.command, .option])
        
        // Simulate live preview before finalizing
        let livePreview = ShortcutFormatter.string(for: shortcut)
        
        XCTAssertEqual(livePreview, "⌥⌘Q",
                      "Should show complete formatted shortcut during live preview")
    }
    
    /// Test modifier preview order matches ShortcutFormatter order.
    func testRecorderFieldDisplay_modifiersInCorrectOrder() {
        let field = ShortcutRecorderField()
        
        let modifiers: NSEvent.ModifierFlags = [.command, .shift, .control, .option]
        let previewText = field.formatModifiers(modifiers)
        
        // Should follow order: control, option, shift, command
        XCTAssertEqual(previewText, "⌃⌥⇧⌘",
                      "Modifiers should display in consistent order")
    }
}
