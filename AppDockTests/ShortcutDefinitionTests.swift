import XCTest
@testable import AppDock

final class ShortcutDefinitionTests: XCTestCase {
    func testModifierMaskStripsNonDeviceIndependentFlags() {
        let modifiers: NSEvent.ModifierFlags = [.command, .shift, .capsLock, .numericPad, .function]
        let shortcut = ShortcutDefinition(keyCode: 12, modifiers: modifiers)

        let mask = shortcut.modifierMask

        XCTAssertEqual(mask, modifiers.intersection(.deviceIndependentFlagsMask))
        XCTAssertTrue(mask.contains(.command))
        XCTAssertTrue(mask.contains(.shift))
    }
}
