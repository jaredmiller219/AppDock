@testable import AppDock
import Carbon
import XCTest

final class ShortcutManagerTests: XCTestCase {
    func testRefreshShortcutsDeduplicatesRegistrations() {
        let registrar = FakeHotKeyRegistrar()
        let sharedShortcut = ShortcutDefinition(keyCode: 12, modifiers: [.command, .option])
        let shortcuts: [ShortcutAction: ShortcutDefinition] = [
            .togglePopover: sharedShortcut,
            .nextPage: sharedShortcut,
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
    
    // MARK: - Edge Cases
    
    func testHotKeyRegistrationFailure() {
        let registrar = FakeHotKeyRegistrar()
        registrar.shouldFailRegistration = true
        
        let manager = ShortcutManager(
            actionHandler: { _ in },
            shortcutProvider: { _ in ShortcutDefinition(keyCode: 14, modifiers: [.command]) },
            registrar: registrar,
            installEventHandler: false
        )
        
        manager.refreshShortcuts()
        
        XCTAssertEqual(registrar.failedRegistrations, 1)
    }
    
    func testSystemShortcutConflicts() {
        let registrar = FakeHotKeyRegistrar()
        let conflictingShortcuts: [ShortcutAction: ShortcutDefinition] = [
            .togglePopover: ShortcutDefinition(keyCode: 3, modifiers: [.command, .option]) // Cmd+Option (Spotlight)
        ]
        
        let conflictManager = ShortcutManager(
            actionHandler: { _ in },
            shortcutProvider: { action in conflictingShortcuts[action] },
            registrar: registrar,
            installEventHandler: false
        )
        
        conflictManager.refreshShortcuts()
        XCTAssertEqual(registrar.registerCalls.count, 1)
    }
    
    func testShortcutDeduplication() {
        let registrar = FakeHotKeyRegistrar()
        let identicalShortcut = ShortcutDefinition(keyCode: 5, modifiers: [.command])
        let identicalShortcuts: [ShortcutAction: ShortcutDefinition] = [
            .togglePopover: identicalShortcut,
            .nextPage: identicalShortcut
        ]
        
        let identicalManager = ShortcutManager(
            actionHandler: { _ in },
            shortcutProvider: { action in identicalShortcuts[action] },
            registrar: registrar,
            installEventHandler: false
        )
        
        identicalManager.refreshShortcuts()
        XCTAssertEqual(registrar.registerCalls.count, 1)
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
    private(set) var failedRegistrations: Int = 0
    private(set) var failedUnregistrations: Int = 0
    
    var shouldFailRegistration: Bool = false
    var shouldFailUnregistration: Bool = false

    func registerHotKey(
        keyCode: UInt32,
        modifiers: UInt32,
        hotKeyId: EventHotKeyID
    ) -> EventHotKeyRef? {
        if shouldFailRegistration {
            failedRegistrations += 1
            return nil
        }
        
        registerCalls.append(RegisterCall(keyCode: keyCode, modifiers: modifiers, hotKeyId: hotKeyId))
        return OpaquePointer(bitPattern: Int(hotKeyId.id) + 1)
    }

    func unregisterHotKey(_ hotKeyRef: EventHotKeyRef) {
        if shouldFailUnregistration {
            failedUnregistrations += 1
            return
        }
        
        unregisterCalls.append(hotKeyRef)
    }
}
