import XCTest
@testable import AppDock

final class ShortcutFormatterTests: XCTestCase {
    func testFormatterOutputsModifiersInExpectedOrder() {
        let shortcut = ShortcutDefinition(keyCode: 12, modifiers: [.command, .shift])

        let formatted = ShortcutFormatter.string(for: shortcut)

        XCTAssertEqual(formatted, "⇧⌘Q")
    }

    func testFormatterOutputsSpecialKeySymbols() {
        let shortcut = ShortcutDefinition(keyCode: 36, modifiers: [.control, .option])

        let formatted = ShortcutFormatter.string(for: shortcut)

        XCTAssertEqual(formatted, "⌃⌥↩")
    }

    func testFormatterOutputsPlainKeyWhenNoModifiers() {
        let shortcut = ShortcutDefinition(keyCode: 49, modifiers: [])

        let formatted = ShortcutFormatter.string(for: shortcut)

        XCTAssertEqual(formatted, "Space")
    }
}
