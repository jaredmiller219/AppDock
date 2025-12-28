//
//  ShortcutManager.swift
//  AppDock
//
/*
 ShortcutManager.swift

 Purpose:
    - Registers and manages global keyboard shortcuts (hot keys) using
        Carbon APIs. Maps registered hot key events back to application actions.

 Overview:
    - `ShortcutManager` is responsible for installing a Carbon event handler,
        (optionally) registering platform hotkeys and invoking an action handler
        callback when a hotkey is pressed.
    - A small `HotKeyRegistrar` protocol isolates registration logic to allow
        easier testing and potential future platform abstraction.
*/

import Carbon
import Cocoa
import os

protocol HotKeyRegistrar {
    func registerHotKey(
        keyCode: UInt32,
        modifiers: UInt32,
        hotKeyId: EventHotKeyID
    ) -> EventHotKeyRef?
    func unregisterHotKey(_ hotKeyRef: EventHotKeyRef)
}

final class CarbonHotKeyRegistrar: HotKeyRegistrar {
    /// Registers a global hot key with the Carbon API.
    ///
    /// - Parameters:
    ///   - keyCode: Hardware key code for the hot key.
    ///   - modifiers: Carbon modifier mask (command/control/option/shift).
    ///   - hotKeyId: Identifier structure used to map the event back to an action.
    /// - Returns: An `EventHotKeyRef` to later unregister, or `nil` on failure.
    func registerHotKey(
        keyCode: UInt32,
        modifiers: UInt32,
        hotKeyId: EventHotKeyID
    ) -> EventHotKeyRef? {
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyId,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        guard status == noErr else { return nil }
        return hotKeyRef
    }

    /// Unregisters a previously-registered Carbon hot key.
    ///
    /// - Parameter hotKeyRef: The reference returned from `registerHotKey`.
    func unregisterHotKey(_ hotKeyRef: EventHotKeyRef) {
        UnregisterEventHotKey(hotKeyRef)
    }
}

final class ShortcutManager {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AppDock", category: "Shortcuts")
    private let actionHandler: (ShortcutAction) -> Void
    private let shortcutProvider: (ShortcutAction) -> ShortcutDefinition?
    private let registrar: HotKeyRegistrar
    private var hotKeyRefs: [ShortcutAction: EventHotKeyRef] = [:]
    private var hotKeyIdMap: [UInt32: ShortcutAction] = [:]
    private var eventHandlerRef: EventHandlerRef?

    /// Create a `ShortcutManager`.
    ///
    /// - Parameters:
    ///   - actionHandler: Callback invoked when a registered `ShortcutAction` is triggered.
    ///   - shortcutProvider: Lookup function to obtain platform `ShortcutDefinition`s.
    ///   - registrar: Platform registrar used to actually install hot keys (testable abstraction).
    ///   - installEventHandler: When `true` installs a Carbon event handler immediately.
    init(
        actionHandler: @escaping (ShortcutAction) -> Void,
        shortcutProvider: @escaping (ShortcutAction) -> ShortcutDefinition? = {
            SettingsDefaults.shortcutValue(forKey: $0.settingsKey)
        },
        registrar: HotKeyRegistrar = CarbonHotKeyRegistrar(),
        installEventHandler: Bool = true
    ) {
        self.actionHandler = actionHandler
        self.shortcutProvider = shortcutProvider
        self.registrar = registrar
        if installEventHandler {
            installHandlerIfNeeded()
        }
    }

    deinit {
        unregisterAll()
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
    }

    /// Refresh (unregister and re-register) all configured shortcuts.
    ///
    /// Useful after Settings changes so the running app picks up new keybindings.
    func refreshShortcuts() {
        unregisterAll()
        registerShortcuts()
    }

    /// Internal: enumerates configured shortcuts and registers them with the registrar.
    ///
    /// - Note: Avoids registering duplicate key/modifier combos and logs failures.
    private func registerShortcuts() {
        var registeredCombos = Set<String>()
        for (index, action) in ShortcutAction.allCases.enumerated() {
            guard let shortcut = shortcutProvider(action) else { continue }
            let comboKey = "\(shortcut.keyCode)-\(shortcut.modifierMask.rawValue)"
            guard !registeredCombos.contains(comboKey) else {
                log("Skipping duplicate shortcut for \(action.rawValue)")
                continue
            }
            registeredCombos.insert(comboKey)

            let hotKeyId = EventHotKeyID(
                signature: ShortcutManager.hotKeySignature,
                id: UInt32(index + 1)
            )
            guard let hotKeyRef = registrar.registerHotKey(
                keyCode: UInt32(shortcut.keyCode),
                modifiers: shortcut.carbonModifiers,
                hotKeyId: hotKeyId
            ) else {
                log("Failed to register shortcut for \(action.rawValue)")
                continue
            }
            hotKeyRefs[action] = hotKeyRef
            hotKeyIdMap[hotKeyId.id] = action
        }
    }

    /// Unregisters and clears all tracked hot key references.
    private func unregisterAll() {
        hotKeyRefs.values.forEach { registrar.unregisterHotKey($0) }
        hotKeyRefs.removeAll()
        hotKeyIdMap.removeAll()
    }

    /// Installs a Carbon event handler that routes `kEventHotKeyPressed` events
    /// back into `handleHotKey(_:)`.
    ///
    /// This is installed once per manager and stores an `EventHandlerRef` for cleanup.
    private func installHandlerIfNeeded() {
        guard eventHandlerRef == nil else { return }
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handler: EventHandlerUPP = { _, event, userData in
            guard let event, let userData else { return noErr }
            let shortcutManager = Unmanaged<ShortcutManager>
                .fromOpaque(userData)
                .takeUnretainedValue()
            shortcutManager.handleHotKey(event)
            return noErr
        }

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventSpec,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandlerRef
        )
        if status != noErr {
            log("Failed to install hot key handler")
        }
    }

    /// Called by the Carbon event handler to translate the low-level event
    /// into a `ShortcutAction` and invoke the configured `actionHandler`.
    private func handleHotKey(_ event: EventRef) {
        var hotKeyId = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyId
        )
        guard status == noErr, hotKeyId.signature == ShortcutManager.hotKeySignature else { return }
        guard let action = hotKeyIdMap[hotKeyId.id] else { return }
        actionHandler(action)
    }

    /// Conditional debug logging helper controlled by `SettingsDefaults.debugLoggingKey`.
    private func log(_ message: String) {
        guard SettingsDefaults.boolValue(
            forKey: SettingsDefaults.debugLoggingKey,
            defaultValue: SettingsDefaults.debugLoggingDefault
        ) else {
            return
        }
        logger.debug("\(message, privacy: .public)")
    }

    private static let hotKeySignature = OSType(0x4150_444B) // "APDK"
}
