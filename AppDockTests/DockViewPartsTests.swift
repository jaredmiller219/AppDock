import XCTest
import SwiftUI
import AppKit
@testable import AppDock

final class DockViewPartsTests: XCTestCase {
    func testButtonViewInteraction_toggleContextMenu() {
        let commandEvent = NSEvent.mouseEvent(
            with: .leftMouseDown,
            location: .zero,
            modifierFlags: [.command],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            eventNumber: 0,
            clickCount: 1,
            pressure: 1.0
        )
        let normalEvent = NSEvent.mouseEvent(
            with: .leftMouseDown,
            location: .zero,
            modifierFlags: [],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            eventNumber: 0,
            clickCount: 1,
            pressure: 1.0
        )

        XCTAssertTrue(ButtonViewInteraction.shouldToggleContextMenu(currentEvent: commandEvent))
        XCTAssertFalse(ButtonViewInteraction.shouldToggleContextMenu(currentEvent: normalEvent))
        XCTAssertFalse(ButtonViewInteraction.shouldToggleContextMenu(currentEvent: nil))
    }

    func testButtonViewInteraction_shouldScheduleRemoveButton() {
        XCTAssertTrue(ButtonViewInteraction.shouldScheduleRemoveButton(
            allowRemove: true,
            isHovering: true,
            isCommandHeld: true
        ))
        XCTAssertFalse(ButtonViewInteraction.shouldScheduleRemoveButton(
            allowRemove: false,
            isHovering: true,
            isCommandHeld: true
        ))
        XCTAssertFalse(ButtonViewInteraction.shouldScheduleRemoveButton(
            allowRemove: true,
            isHovering: false,
            isCommandHeld: true
        ))
        XCTAssertFalse(ButtonViewInteraction.shouldScheduleRemoveButton(
            allowRemove: true,
            isHovering: true,
            isCommandHeld: false
        ))
        XCTAssertEqual(ButtonViewInteraction.removeButtonDelay, 0.5)
    }

    func testContextMenuViewPrompt_values() {
        XCTAssertTrue(ContextMenuViewPrompt.requiresConfirmation(confirmBeforeQuit: true))
        XCTAssertFalse(ContextMenuViewPrompt.requiresConfirmation(confirmBeforeQuit: false))
        XCTAssertEqual(ContextMenuViewPrompt.quitTitle(for: ""), "Quit this app?")
        XCTAssertEqual(ContextMenuViewPrompt.quitTitle(for: "Notes"), "Quit Notes?")
        XCTAssertEqual(ContextMenuViewPrompt.accessibilityId, "DockContextMenu")
    }

    func testEmptySlotConstants_values() {
        XCTAssertEqual(EmptySlotConstants.labelText, "Empty")
        XCTAssertEqual(EmptySlotConstants.cornerRadius, 5)
        XCTAssertEqual(EmptySlotConstants.strokeOpacity, 0.4)
        XCTAssertEqual(EmptySlotConstants.fontSize, 8)
        XCTAssertEqual(EmptySlotConstants.accessibilityId, "DockEmptySlot")
    }

    func testIconViewConstants_values() {
        XCTAssertEqual(IconViewConstants.cornerRadius, 8)
        XCTAssertEqual(IconViewConstants.accessibilityIdPrefix, "DockIcon-")
    }

    func testVisualEffectBlur_makeAndUpdate() {
        let initial = VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
        let context = NSViewRepresentableContext<VisualEffectBlur>(coordinator: ())
        let view = initial.makeNSView(context: context)

        XCTAssertEqual(view.material, .hudWindow)
        XCTAssertEqual(view.blendingMode, .withinWindow)
        XCTAssertEqual(view.state, .active)

        let updated = VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow)
        updated.updateNSView(view, context: context)

        XCTAssertEqual(view.material, .sidebar)
        XCTAssertEqual(view.blendingMode, .behindWindow)
        XCTAssertEqual(view.state, .active)
    }

    func testAppDockDismissContextMenuNotificationName() {
        XCTAssertEqual(Notification.Name.appDockDismissContextMenu.rawValue, "AppDockDismissContextMenu")
    }
}
