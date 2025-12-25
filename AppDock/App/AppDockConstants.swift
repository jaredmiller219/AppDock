//
//  AppDockConstants.swift
//  AppDock
//

import Foundation
import CoreGraphics

public enum AppDockConstants {
    public enum SettingsUI {
        public static let minWidth: CGFloat = 560
        public static let minHeight: CGFloat = 560
        public static let sidebarWidth: CGFloat = 160
    }

    public enum Accessibility {
        public static let dockSlotPrefix = "DockSlot-"
        public static let dockFilterMenu = "DockFilterMenu"
        public static let menuRowPrefix = "MenuRow-"
        public static let contextMenu = "DockContextMenu"
        public static let emptySlot = "DockEmptySlot"
        public static let iconPrefix = "DockIcon-"
        public static let statusItem = "AppDockStatusItem"
        public static let statusItemLabel = "AppDock"
        public static let uiTestWindow = "AppDock UI Test"
    }

    public enum Timing {
        public static let removeButtonDelay: TimeInterval = 0.5
    }

    public enum EmptySlot {
        public static let labelText = "Empty"
        public static let cornerRadius: CGFloat = 5
        public static let strokeOpacity: Double = 0.4
        public static let fontSize: CGFloat = 8
    }

    public enum IconView {
        public static let cornerRadius: CGFloat = 8
    }

    public enum Testing {
        public static let uiTestMode = "--ui-test-mode"
        public static let uiTestOpenPopover = "--ui-test-open-popover"
        public static let uiTestSeedDock = "--ui-test-seed-dock"
        public static let uiTestDisableActivation = "--ui-test-disable-activation"
        public static let uiTestOpenSettings = "--ui-test-open-settings"
        public static let uiTestOpenPopovers = "--ui-test-open-popovers"
    }
}
