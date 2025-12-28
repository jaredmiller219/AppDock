//
//  ShortcutRecorderView.swift
//  AppDock
//

import SwiftUI
import AppKit

struct ShortcutRecorder: NSViewRepresentable {
    @Binding var shortcut: ShortcutDefinition?
    var accessibilityIdentifier: String?

    func makeCoordinator() -> Coordinator {
        Coordinator(shortcut: $shortcut)
    }

    func makeNSView(context: Context) -> ShortcutRecorderField {
        let field = ShortcutRecorderField()
        field.onShortcutChange = { context.coordinator.shortcut.wrappedValue = $0 }
        field.onEditingStateChange = { isEditing in
            context.coordinator.isEditing = isEditing
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
        nsView.updateDisplay(with: shortcut, isEditing: context.coordinator.isEditing)
    }

    final class Coordinator {
        var shortcut: Binding<ShortcutDefinition?>
        var isEditing = false

        init(shortcut: Binding<ShortcutDefinition?>) {
            self.shortcut = shortcut
        }
    }
}

final class ShortcutRecorderField: NSTextField {
    var onShortcutChange: ((ShortcutDefinition?) -> Void)?
    var onEditingStateChange: ((Bool) -> Void)?
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
            stringValue = "Type Shortcut"
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

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
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
        guard !modifiers.intersection(requiredModifiers).isEmpty else {
            NSSound.beep()
            return
        }

        let shortcut = ShortcutDefinition(keyCode: event.keyCode, modifiers: modifiers)
        onShortcutChange?(shortcut)
        window?.makeFirstResponder(nil)
    }

    func updateDisplay(with shortcut: ShortcutDefinition?, isEditing: Bool) {
        if isEditing {
            stringValue = "Type Shortcut"
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
        47: "."
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
