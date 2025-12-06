//
//  MenuController.swift
//  AppDock
//
//  Created by Jared Miller on 12/17/24.
//

// Import the SwiftUI framework for user interface components
import SwiftUI

// Import Foundation framework for basic functionality
import Foundation

// Define the AppMenu class that manages the status bar menu
// Inherits from NSObject to work with Objective-C runtime
class MenuController: NSObject {
    
    // Create a hosting controller for the popover content
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
        hostingController.view.frame.size = CGSize(width: 260, height: 460)
        return hostingController
    }
}

struct PopoverContentView: View {
    @ObservedObject var appState: AppState
    let settingsAction: () -> Void
    let aboutAction: () -> Void
    let quitAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                DockView(appState: appState)
                    .padding(.horizontal, 8)
                    .padding(.top, 6)
                    .padding(.bottom, 10)
            }
            
            Divider()
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            
            VStack(spacing: 0) {
                MenuRow(title: "Settings", action: settingsAction)
                Divider()
                MenuRow(title: "About", action: aboutAction)
                Divider()
                MenuRow(title: "Quit AppDock", action: quitAction)
            }
            .padding(.bottom, 6)
        }
        .frame(width: 260, height: 460, alignment: .top)
    }
}

private struct MenuRow: View {
    let title: String
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovering ? Color.primary.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: 6))
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
