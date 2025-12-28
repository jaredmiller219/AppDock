//
//  ShortcutManager.swift
//  AppDock
//

import Cocoa
import Carbon
import os

final class ShortcutManager {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AppDock", category: "Shortcuts")
    private let actionHandler: (ShortcutAction) -> Void
    private var hotKeyRefs: [ShortcutAction: EventHotKeyRef] = [:]
    private var hotKeyIdMap: [UInt32: ShortcutAction] = [:]
    private var eventHandlerRef: EventHandlerRef?

    init(actionHandler: @escaping (ShortcutAction) -> Void) {
        self.actionHandler = actionHandler
        installHandlerIfNeeded()
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
            guard let shortcut = SettingsDefaults.shortcutValue(forKey: action.settingsKey) else { continue }
            let comboKey = "\(shortcut.keyCode)-\(shortcut.modifierMask.rawValue)"
            guard !registeredCombos.contains(comboKey) else {
                log("Skipping duplicate shortcut for \(action.rawValue)")
                continue
            }
            registeredCombos.insert(comboKey)

            var hotKeyRef: EventHotKeyRef?
            let hotKeyId = EventHotKeyID(
                signature: ShortcutManager.hotKeySignature,
                id: UInt32(index + 1)
            )
            let status = RegisterEventHotKey(
                UInt32(shortcut.keyCode),
                shortcut.carbonModifiers,
                hotKeyId,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )
            guard status == noErr, let hotKeyRef else {
                log("Failed to register shortcut for \(action.rawValue)")
                continue
            }
            hotKeyRefs[action] = hotKeyRef
            hotKeyIdMap[hotKeyId.id] = action
        }
    }

    private func unregisterAll() {
        hotKeyRefs.values.forEach { UnregisterEventHotKey($0) }
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
