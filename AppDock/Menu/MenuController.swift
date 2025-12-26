//
//  MenuController.swift
//  AppDock
//
//  Created by Jared Miller on 12/17/24.
//

// Import the SwiftUI framework for user interface components.
import SwiftUI

// Import Foundation framework for basic functionality.
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
        settingsAction: @escaping () -> Void,
        aboutAction: @escaping () -> Void,
        quitAction: @escaping () -> Void
    ) -> NSViewController {
        let contentView = PopoverContentView(
            appState: appState,
            settingsAction: settingsAction,
            aboutAction: aboutAction,
            quitAction: quitAction
        )
        let hostingController = NSHostingController(rootView: contentView)
        hostingController.view.frame.size = PopoverSizing.size(for: appState)
        return hostingController
    }
}
