//
//  AppDockConstants.swift
//  AppDock
//

import Foundation
import CoreGraphics

enum AppDockConstants {
    enum SettingsUI {
        static let minWidth: CGFloat = 560
        static let minHeight: CGFloat = 560
        static let sidebarWidth: CGFloat = 160
    }

    enum Accessibility {
        static let dockSlotPrefix = "DockSlot-"
        static let dockFilterMenu = "DockFilterMenu"
        static let menuRowPrefix = "MenuRow-"
        static let contextMenu = "DockContextMenu"
        static let emptySlot = "DockEmptySlot"
        static let iconPrefix = "DockIcon-"
        static let statusItem = "AppDockStatusItem"
        static let statusItemLabel = "AppDock"
    }

    enum Timing {
        static let removeButtonDelay: TimeInterval = 0.5
    }

    enum EmptySlot {
        static let labelText = "Empty"
        static let cornerRadius: CGFloat = 5
        static let strokeOpacity: Double = 0.4
        static let fontSize: CGFloat = 8
    }

    enum IconView {
        static let cornerRadius: CGFloat = 8
    }

    enum Testing {
        static let uiTestMode = "--ui-test-mode"
        static let uiTestOpenPopover = "--ui-test-open-popover"
        static let uiTestSeedDock = "--ui-test-seed-dock"
        static let uiTestDisableActivation = "--ui-test-disable-activation"
    }
}
