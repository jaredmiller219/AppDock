//
//  MenuController.swift
//  AppDock
//
/*
 MenuController.swift

 Purpose:
    - Bridge between AppKit popover hosting and SwiftUI content. Exposes a
        small API to create an `NSViewController` hosting the SwiftUI popover
        content sized to `AppState` and current settings.

 Overview:
    - Provides `PopoverSizing` helpers and a `MenuController` factory method
        `makePopoverController(...)` so higher-level code can avoid AppKit/SwiftUI
        interop details.
*/

import SwiftUI
import Foundation

// MARK: - Menu Controller

/// Centralizes popover sizing so content and AppKit stay in sync.
enum PopoverSizing {
    static var defaultWidth: CGFloat { AppDockConstants.MenuPopover.defaultWidth }
    static var height: CGFloat { AppDockConstants.MenuPopover.height }
    static var columnSpacing: CGFloat { AppDockConstants.MenuPopover.columnSpacing }

    static func width(for appState: AppState) -> CGFloat {
        let extraColumns = max(0, appState.gridColumns - SettingsDefaults.gridColumnsDefault)
        let columnIncrement = CGFloat(appState.iconSize) + columnSpacing
        return defaultWidth + CGFloat(extraColumns) * columnIncrement
    }

    static func size(for appState: AppState) -> NSSize {
        NSSize(width: width(for: appState), height: height)
    }
}

/// Hosts the SwiftUI popover content inside an AppKit view controller.
///
/// This wrapper keeps AppKit/SwiftUI interop isolated from the rest of the app.
class MenuController: NSObject {
    /// Creates a popover controller for the dock and menu actions.
    func makePopoverController(
        appState: AppState,
        menuState: MenuState,
        settingsAction: @escaping () -> Void,
        aboutAction: @escaping () -> Void,
        shortcutsAction: @escaping () -> Void,
        helpAction: @escaping () -> Void,
        releaseNotesAction: @escaping () -> Void,
        appGroupsAction: @escaping () -> Void,
        quitAction: @escaping () -> Void
    ) -> NSViewController {
        let contentView = PopoverContentView(
            appState: appState,
            menuState: menuState,
            settingsAction: settingsAction,
            aboutAction: aboutAction,
            shortcutsAction: shortcutsAction,
            helpAction: helpAction,
            releaseNotesAction: releaseNotesAction,
            appGroupsAction: appGroupsAction,
            quitAction: quitAction
        )
        let hostingController = NSHostingController(rootView: contentView)
        hostingController.view.frame.size = PopoverSizing.size(for: appState)
        return hostingController
    }
}
