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
        hostingController.view.frame.size = CGSize(width: 220, height: 380)
        return hostingController
    }
}

struct PopoverContentView: View {
    @ObservedObject var appState: AppState
    let settingsAction: () -> Void
    let aboutAction: () -> Void
    let quitAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            DockView(appState: appState)
                .padding(.top, 6)
            
            Spacer(minLength: 0)
            
            Divider()
            
            HStack {
                Button("Settings") { settingsAction() }
                Spacer()
                Button("About") { aboutAction() }
                Spacer()
                Button("Quit") { quitAction() }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
        }
        .padding(.horizontal, 8)
        .frame(width: 220, height: 380, alignment: .top)
    }
}
