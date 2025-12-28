//
//  MenuAppRow.swift
//  AppDock
//

import AppKit
import SwiftUI

struct MenuAppRow: View {
    let app: AppState.AppEntry
    let appState: AppState
    @State private var isHovering = false

    private func openApp(bundleId: String) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return
        }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.createsNewApplicationInstance = false
        NSWorkspace.shared.openApplication(
            at: appURL,
            configuration: configuration,
            completionHandler: nil
        )
    }

    private func activateOrLaunchApp(bundleId: String) {
        if ProcessInfo.processInfo.arguments.contains(AppDockConstants.Testing.uiTestDisableActivation) {
            if ProcessInfo.processInfo.arguments.contains(AppDockConstants.Testing.uiTestMode) {
                appState.uiTestLastActivationBundleId = bundleId
            }
            return
        }
        guard !bundleId.isEmpty else { return }

        if let targetApp = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleId)
            .first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier })
        {
            targetApp.unhide()
            targetApp.activate(options: [.activateAllWindows])
            openApp(bundleId: bundleId)
        } else {
            openApp(bundleId: bundleId)
        }
    }

    var body: some View {
        Button {
            activateOrLaunchApp(bundleId: app.bundleid)
        } label: {
            HStack(spacing: AppDockConstants.MenuAppRow.spacing) {
                Image(nsImage: app.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: AppDockConstants.MenuAppRow.iconSize, height: AppDockConstants.MenuAppRow.iconSize)
                    .cornerRadius(AppDockConstants.MenuAppRow.iconCornerRadius)
                    .accessibilityHidden(true)

                Text(app.name)
                    .font(.callout)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, AppDockConstants.MenuAppRow.paddingHorizontal)
            .padding(.vertical, AppDockConstants.MenuAppRow.paddingVertical)
            .background(
                RoundedRectangle(cornerRadius: AppDockConstants.MenuAppRow.cornerRadius)
                    .fill(isHovering ? Color.primary.opacity(0.1) : Color.primary.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: AppDockConstants.MenuAppRow.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(app.name))
        .accessibilityHint(Text("Open app"))
        .accessibilityIdentifier(
            AppDockConstants.Accessibility.menuAppRowPrefix + (app.bundleid.isEmpty ? app.name : app.bundleid)
        )
        .onHover { hovering in
            isHovering = hovering
        }
        .disabled(app.bundleid.isEmpty)
    }
}
