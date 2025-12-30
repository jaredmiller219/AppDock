/*
 ShortcutRecorderView.swift
 AppDock

 PURPOSE:
 This file provides a custom NSTextField-based shortcut recorder for capturing global keyboard shortcuts.
 Bridges AppKit NSTextField UI with SwiftUI through NSViewRepresentable.

 OVERVIEW:
 ShortcutRecorder is an NSViewRepresentable that wraps ShortcutRecorderField (a custom NSTextField subclass).
 
 When the field gains focus, it enters "recording mode" and listens for keyboard input.
 Key events are parsed to extract key code and modifier flags, assembled into ShortcutDefinition.
 The Delete key clears the shortcut; Escape or focus loss exits recording without saving.

 COMPONENTS:
 - ShortcutRecorder: SwiftUI wrapper using NSViewRepresentable
 - Coordinator: Holds Bindings to shortcut and isEditing state
 - ShortcutRecorderField: Custom NSTextField managing keyboard capture and display
 
 INTERACTION FLOW:
 1. User clicks field -> becomeFirstResponder -> enter recording mode
 2. Field shows "Recording..." while waiting for keyboard input
 3. User presses key combo -> keyDown intercepts -> parses modifiers + keyCode
 4. ShortcutDefinition assembled -> onShortcutChange callback -> binding updated
 5. User releases keys or presses Escape -> resignFirstResponder -> exit recording
 6. Field updates display with recorded shortcut or clears if Delete pressed

 ACCESSIBILITY:
 - Supports accessibility identifiers for testing
 - Keyboard accessible (Tab to focus, Enter to activate)
*/

import AppKit
import SwiftUI

/// NSViewRepresentable wrapper for keyboard shortcut recording field.
/// 
/// Bridges AppKit NSTextField-based shortcut input with SwiftUI state management.
/// Allows users to record global keyboard shortcuts via click-to-focus interaction.
struct ShortcutRecorder: NSViewRepresentable {
    /// Binding to optional ShortcutDefinition being recorded
    @Binding var shortcut: ShortcutDefinition?
    
    /// Optional accessibility identifier for testing
    var accessibilityIdentifier: String?
    
    /// Binding tracking whether field is actively recording keyboard input
    @Binding var isEditing: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(shortcut: $shortcut, isEditing: $isEditing)
    }

    func makeNSView(context: Context) -> ShortcutRecorderField {
        let field = ShortcutRecorderField()
        field.onShortcutChange = { context.coordinator.shortcut.wrappedValue = $0 }
        field.onEditingStateChange = { isEditing in
            context.coordinator.isEditing.wrappedValue = isEditing
        }
        if let accessibilityIdentifier {
            field.setAccessibilityIdentifier(accessibilityIdentifier)
        }
        field.updateDisplay(with: shortcut, isEditing: false)
        return field
    }

    func updateNSView(_ nsView: ShortcutRecorderField, context: Context) {
        if let accessibilityIdentifier {
            nsView.setAccessibilityIdentifier(accessibilityIdentifier)
        }
        nsView.updateDisplay(with: shortcut, isEditing: context.coordinator.isEditing.wrappedValue)
    }

    /// Coordinator holding NSView bindings for SwiftUI integration.
    /// 
    /// Maintains references to shortcut and isEditing bindings,
    /// allowing the NSTextField to update SwiftUI state.
    final class Coordinator {
        /// Binding to shortcut being recorded (updated by NSView)
        var shortcut: Binding<ShortcutDefinition?>
        
        /// Binding to editing state (updated by NSView)
        var isEditing: Binding<Bool>

        init(shortcut: Binding<ShortcutDefinition?>, isEditing: Binding<Bool>) {
            self.shortcut = shortcut
            self.isEditing = isEditing
        }
    }
}

/// Custom NSTextField for capturing and displaying keyboard shortcuts.
/// 
/// Handles keyboard event capture during recording mode, parses key codes and modifiers,
/// and updates UI display. Supports Delete key to clear shortcuts and Escape to cancel.
final class ShortcutRecorderField: NSTextField {
    /// Callback when user successfully records a shortcut (includes nil for cleared)
    var onShortcutChange: ((ShortcutDefinition?) -> Void)?
    
    /// Callback when recording state changes (entered/exited)
    var onEditingStateChange: ((Bool) -> Void)?
    
    /// Local flag tracking whether field is in recording mode (focused and listening)
    private var isEditing = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        isEditable = false
        isSelectable = false
        isBezeled = true
        bezelStyle = .roundedBezel
        focusRingType = .default
        alignment = .center
        setAccessibilityElement(true)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func becomeFirstResponder() -> Bool {
        let became = super.becomeFirstResponder()
        if became {
            isEditing = true
            onEditingStateChange?(true)
            stringValue = "Recording..."
        }
        return became
    }

    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        if resigned {
            isEditing = false
            onEditingStateChange?(false)
        }
        return resigned
    }

    override func mouseDown(with _: NSEvent) {
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if event.keyCode == 53 {
            onEditingStateChange?(false)
            window?.makeFirstResponder(nil)
            return
        }
        if isClearKey(event.keyCode) {
            onShortcutChange?(nil)
            window?.makeFirstResponder(nil)
            return
        }
        if isModifierKey(event.keyCode) {
            NSSound.beep()
            return
        }
        let requiredModifiers: NSEvent.ModifierFlags = [.command, .option, .control]
        guard !modifiers.isDisjoint(with: requiredModifiers) else {
            NSSound.beep()
            return
        }

        let shortcut = ShortcutDefinition(keyCode: event.keyCode, modifiers: modifiers)
        onShortcutChange?(shortcut)
        window?.makeFirstResponder(nil)
    }

    func updateDisplay(with shortcut: ShortcutDefinition?, isEditing: Bool) {
        if isEditing {
            stringValue = "Recording..."
            setAccessibilityValue(stringValue)
            setAccessibilityLabel(stringValue)
            setAccessibilityTitle(stringValue)
            return
        }
        if let shortcut {
            stringValue = ShortcutFormatter.string(for: shortcut)
        } else {
            stringValue = "Record Shortcut"
        }
        setAccessibilityValue(stringValue)
        setAccessibilityLabel(stringValue)
        setAccessibilityTitle(stringValue)
    }

    private func isModifierKey(_ keyCode: UInt16) -> Bool {
        switch keyCode {
        case 54, 55, 56, 57, 58, 59, 60, 61, 62:
            return true
        default:
            return false
        }
    }

    private func isClearKey(_ keyCode: UInt16) -> Bool {
        keyCode == 51 || keyCode == 117
    }
}

enum ShortcutFormatter {
    private static let keyLabels: [UInt16: String] = [
        36: "↩",
        48: "⇥",
        49: "Space",
        51: "⌫",
        53: "⎋",
        123: "←",
        124: "→",
        125: "↓",
        126: "↑",
        115: "Home",
        119: "End",
        116: "⇞",
        121: "⇟",
        122: "F1",
        120: "F2",
        99: "F3",
        118: "F4",
        96: "F5",
        97: "F6",
        98: "F7",
        100: "F8",
        101: "F9",
        109: "F10",
        103: "F11",
        111: "F12",
        0: "A",
        1: "S",
        2: "D",
        3: "F",
        4: "H",
        5: "G",
        6: "Z",
        7: "X",
        8: "C",
        9: "V",
        11: "B",
        12: "Q",
        13: "W",
        14: "E",
        15: "R",
        16: "Y",
        17: "T",
        18: "1",
        19: "2",
        20: "3",
        21: "4",
        22: "6",
        23: "5",
        24: "=",
        25: "9",
        26: "7",
        27: "-",
        28: "8",
        29: "0",
        30: "]",
        31: "O",
        32: "U",
        33: "[",
        34: "I",
        35: "P",
        37: "L",
        38: "J",
        39: "'",
        40: "K",
        41: ";",
        42: "\\",
        43: ",",
        44: "/",
        45: "N",
        46: "M",
        47: ".",
    ]

    static func string(for shortcut: ShortcutDefinition) -> String {
        let modifiers = shortcut.modifierMask
        var parts: [String] = []
        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }
        let keyLabel = keyLabels[shortcut.keyCode] ?? "Key \(shortcut.keyCode)"
        parts.append(keyLabel)
        return parts.joined()
    }
}
