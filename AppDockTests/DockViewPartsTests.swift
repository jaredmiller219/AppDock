@testable import AppDock
import AppKit
import SwiftUI
import XCTest

final class DockViewPartsTests: XCTestCase {
    func testButtonViewInteraction_toggleContextMenu() {
        // Command-click should toggle context menus while regular click should not.
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
        // Hover + command should schedule the remove button; any missing condition should not.
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
        XCTAssertEqual(AppDockConstants.Timing.removeButtonDelay, 0.5)
    }

    func testContextMenuViewPrompt_values() {
        // Confirm the prompt text and confirmation gate are stable.
        XCTAssertTrue(ContextMenuViewPrompt.requiresConfirmation(confirmBeforeQuit: true))
        XCTAssertFalse(ContextMenuViewPrompt.requiresConfirmation(confirmBeforeQuit: false))
        XCTAssertEqual(ContextMenuViewPrompt.quitTitle(for: ""), "Quit this app?")
        XCTAssertEqual(ContextMenuViewPrompt.quitTitle(for: "Notes"), "Quit Notes?")
        XCTAssertEqual(AppDockConstants.Accessibility.contextMenu, "DockContextMenu")
    }

    func testEmptySlotConstants_values() {
        // Ensure EmptySlot uses stable UI constants for tests and layout.
        XCTAssertEqual(AppDockConstants.EmptySlot.labelText, "Empty")
        XCTAssertEqual(AppDockConstants.EmptySlot.cornerRadius, 5)
        XCTAssertEqual(AppDockConstants.EmptySlot.strokeOpacity, 0.4)
        XCTAssertEqual(AppDockConstants.EmptySlot.fontSize, 8)
        XCTAssertEqual(AppDockConstants.Accessibility.emptySlot, "DockEmptySlot")
    }

    func testIconViewConstants_values() {
        // Verify IconView constants for accessibility/testing.
        XCTAssertEqual(AppDockConstants.IconView.cornerRadius, 8)
        XCTAssertEqual(AppDockConstants.Accessibility.iconPrefix, "DockIcon-")
    }

    func testVisualEffectBlur_makeAndUpdate() {
        // Exercise both NSViewRepresentable creation and update paths.
        let view = NSVisualEffectView()
        VisualEffectBlur.configure(view, material: .hudWindow, blendingMode: .withinWindow)

        XCTAssertEqual(view.material, .hudWindow)
        XCTAssertEqual(view.blendingMode, .withinWindow)
        XCTAssertEqual(view.state, .active)

        VisualEffectBlur.configure(view, material: .sidebar, blendingMode: .behindWindow)

        XCTAssertEqual(view.material, .sidebar)
        XCTAssertEqual(view.blendingMode, .behindWindow)
        XCTAssertEqual(view.state, .active)
    }

    func testAppDockDismissContextMenuNotificationName() {
        // Keep the notification name stable for menu dismissal broadcasts.
        XCTAssertEqual(Notification.Name.appDockDismissContextMenu.rawValue, "AppDockDismissContextMenu")
    }
}
