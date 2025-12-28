//
//  ShortcutManager.swift
//  AppDock
//

import Cocoa
import Carbon
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

    func refreshShortcuts() {
        unregisterAll()
        registerShortcuts()
    }

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

    private func unregisterAll() {
        hotKeyRefs.values.forEach { registrar.unregisterHotKey($0) }
        hotKeyRefs.removeAll()
        hotKeyIdMap.removeAll()
    }

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

    private func log(_ message: String) {
        guard SettingsDefaults.boolValue(
            forKey: SettingsDefaults.debugLoggingKey,
            defaultValue: SettingsDefaults.debugLoggingDefault
        ) else {
            return
        }
        logger.debug("\(message, privacy: .public)")
    }

    private static let hotKeySignature = OSType(0x4150444B) // "APDK"
}
