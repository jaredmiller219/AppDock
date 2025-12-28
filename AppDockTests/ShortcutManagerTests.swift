import XCTest
import Carbon
@testable import AppDock

final class ShortcutManagerTests: XCTestCase {
    func testRefreshShortcutsDeduplicatesRegistrations() {
        let registrar = FakeHotKeyRegistrar()
        let sharedShortcut = ShortcutDefinition(keyCode: 12, modifiers: [.command, .option])
        let shortcuts: [ShortcutAction: ShortcutDefinition] = [
            .togglePopover: sharedShortcut,
            .nextPage: sharedShortcut
        ]

        let manager = ShortcutManager(
            actionHandler: { _ in },
            shortcutProvider: { shortcuts[$0] },
            registrar: registrar,
            installEventHandler: false
        )

        manager.refreshShortcuts()

        XCTAssertEqual(registrar.registerCalls.count, 1)
    }

    func testRefreshShortcutsUnregistersPreviousKeys() {
        let registrar = FakeHotKeyRegistrar()
        let shortcut = ShortcutDefinition(keyCode: 14, modifiers: [.command])
        let manager = ShortcutManager(
            actionHandler: { _ in },
            shortcutProvider: { _ in shortcut },
            registrar: registrar,
            installEventHandler: false
        )

        manager.refreshShortcuts()
        manager.refreshShortcuts()

        XCTAssertEqual(registrar.registerCalls.count, 2)
        XCTAssertEqual(registrar.unregisterCalls.count, 1)
    }
}

private final class FakeHotKeyRegistrar: HotKeyRegistrar {
    struct RegisterCall {
        let keyCode: UInt32
        let modifiers: UInt32
        let hotKeyId: EventHotKeyID
    }

    private(set) var registerCalls: [RegisterCall] = []
    private(set) var unregisterCalls: [EventHotKeyRef] = []

    func registerHotKey(
        keyCode: UInt32,
        modifiers: UInt32,
        hotKeyId: EventHotKeyID
    ) -> EventHotKeyRef? {
        registerCalls.append(RegisterCall(keyCode: keyCode, modifiers: modifiers, hotKeyId: hotKeyId))
        return OpaquePointer(bitPattern: Int(hotKeyId.id) + 1)
    }

    func unregisterHotKey(_ hotKeyRef: EventHotKeyRef) {
        unregisterCalls.append(hotKeyRef)
    }
}
