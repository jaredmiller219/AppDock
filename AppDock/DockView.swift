//
//  DockView.swift
//  AppDock
//
//  Created by Jared Miller on 12/12/24.
//

import SwiftUI
import AppKit

// MARK: - ButtonView

struct ButtonView: View {
	let appName: String
	let bundleId: String
	let appIcon: NSImage
	let buttonWidth: CGFloat
	let buttonHeight: CGFloat
	
	// Controls whether THIS button's context menu is visible
	@Binding var isContextMenuVisible: Bool
	
	// Called when the user taps the "X" remove button
	let onRemove: () -> Void
	
	@State private var isHovering = false
	@State private var showRemoveButton = false
	@State private var removeButtonWorkItem: DispatchWorkItem?
	@State private var isCommandHeld = false
	@State private var modifierFlagsMonitor: Any?
	@State private var globalModifierFlagsMonitor: Any?

	var body: some View {
		ZStack(alignment: .topLeading) {
			Group {
						if appName.isEmpty {
							EmptySlot(width: buttonWidth, height: buttonHeight)
						} else {
							Button {
								if let event = NSApp.currentEvent,
								   event.modifierFlags.contains(.command) {
									// Command-click: toggle this button's context menu
									isContextMenuVisible.toggle()
								} else {
									// Any regular click closes all context menus first
									isContextMenuVisible = false
									// Regular click: activate the app
									if !bundleId.isEmpty,
									   let targetApp = NSRunningApplication
										.runningApplications(withBundleIdentifier: bundleId)
										.first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) {
								targetApp.activate()
							}
						}
					} label: {
						IconView(
							appName: appName,
							appIcon: appIcon,
							width: buttonWidth,
							height: buttonHeight
						)
						.overlay(
							RoundedRectangle(cornerRadius: 8)
								.stroke(isHovering ? Color.blue : Color.clear, lineWidth: 2)
						)
					}
					.buttonStyle(.plain)
				}
			}
			
			// Remove "X" button overlay in top-left
			if showRemoveButton && !appName.isEmpty {
				Button {
					onRemove()
				} label: {
					Image(systemName: "xmark.circle.fill")
						.font(.system(size: 10, weight: .bold))
						.contentShape(Rectangle()) // nicer tap target
				}
				.buttonStyle(.plain)
				.padding(2)
			}
		}
		// Context menu overlay above the icon
		.overlay(alignment: .top) {
			if isContextMenuVisible && !appName.isEmpty {
				ContextMenuView(
					onDismiss: { isContextMenuVisible = false },
					bundleId: bundleId
				)
				.padding(4)
				.background(
					RoundedRectangle(cornerRadius: 8)
						.fill(Color(NSColor.windowBackgroundColor))
						.shadow(radius: 6)
				)
				.offset(y: -buttonHeight / 2 - 8)
				.zIndex(1)
			}
		}
		// Attach hover to the whole cell (icon + X), so moving onto the X doesn't "leave"
		.onHover { hovering in
			isHovering = hovering
			
			if hovering {
				let commandIsDown = isCommandHeld || (NSApp.currentEvent?.modifierFlags.contains(.command) ?? false)

				// Only schedule the "X" if Command is held
				if commandIsDown {
					scheduleRemoveButton()
				} else {
					cancelRemoveButton()
				}
			} else {
				// Actually left the button area: hide X
				cancelRemoveButton()
			}
		}
		.onAppear {
			startMonitoringModifierFlags()
		}
		.onDisappear {
			stopMonitoringModifierFlags()
		}
		.disabled(bundleId.isEmpty)
	}

	// MARK: - Modifier key monitoring

	private func startMonitoringModifierFlags() {
		if modifierFlagsMonitor != nil { return }

		isCommandHeld = NSEvent.modifierFlags.contains(.command)

		modifierFlagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
			handleModifierFlagsChange(event)
			return event
		}

		// Also listen globally so Command presses register even if the window isn't key yet
		globalModifierFlagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
			handleModifierFlagsChange(event)
		}
	}

	private func stopMonitoringModifierFlags() {
		if let monitor = modifierFlagsMonitor {
			NSEvent.removeMonitor(monitor)
			modifierFlagsMonitor = nil
		}

		if let globalMonitor = globalModifierFlagsMonitor {
			NSEvent.removeMonitor(globalMonitor)
			globalModifierFlagsMonitor = nil
		}
	}

	private func handleModifierFlagsChange(_ event: NSEvent) {
		let commandIsDown = event.modifierFlags.contains(.command)
		isCommandHeld = commandIsDown

		if commandIsDown {
			if isHovering {
				scheduleRemoveButton()
			}
		} else {
			cancelRemoveButton()
		}
	}

	// MARK: - Remove button timing

	private func scheduleRemoveButton() {
		removeButtonWorkItem?.cancel()
		
		let workItem = DispatchWorkItem {
			if isHovering {
				showRemoveButton = true
			}
		}
		removeButtonWorkItem = workItem
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
	}
	
	private func cancelRemoveButton() {
		removeButtonWorkItem?.cancel()
		removeButtonWorkItem = nil
		showRemoveButton = false
	}
}

// MARK: - ContextMenuView

struct ContextMenuView: View {
	var onDismiss: () -> Void
	let bundleId: String
	
	var body: some View {
		VStack(spacing: 6) {
			Button("Hide App") {
				if let app = NSRunningApplication
					.runningApplications(withBundleIdentifier: bundleId)
					.first {
					print("Hiding app with bundle ID: \(bundleId)")
					app.hide()
				}
				onDismiss()
			}
			
			Button("Quit App") {
				if let targetApp = NSRunningApplication
					.runningApplications(withBundleIdentifier: bundleId)
					.first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) {
					print("Quitting app with bundle ID: \(bundleId)")
					targetApp.terminate()
				}
				onDismiss()
			}
		}
		.padding(8)
		.frame(width: 120)
	}
}

// MARK: - EmptySlot

struct EmptySlot: View {
	let width: CGFloat
	let height: CGFloat
	
	var body: some View {
		Color.clear
			.frame(width: width, height: height)
			.overlay(
				RoundedRectangle(cornerRadius: 5)
					.stroke(Color.gray.opacity(0.4), lineWidth: 1)
			)
			.overlay(
				Text("Empty")
					.foregroundColor(.gray)
					.font(.system(size: 8))
			)
	}
}

// MARK: - IconView

struct IconView: View {
	let appName: String
	let appIcon: NSImage
	let width: CGFloat
	let height: CGFloat
	
	var body: some View {
		Image(nsImage: appIcon)
			.resizable()
			.scaledToFit()
			.frame(width: width, height: height)
			.cornerRadius(8)
	}
}

// MARK: - DockView

struct DockView: View {
	@ObservedObject var appState: AppState
	
	// Tracks which app index currently has its context menu open
	@State private var activeContextMenuIndex: Int? = nil
	@State private var mouseMonitor: Any?
	@State private var localMouseMonitor: Any?
	
	private func dismissContextMenus() {
		activeContextMenuIndex = nil
	}
	
	let numberOfColumns: Int = 3
	let numberOfRows: Int = 4
	let buttonWidth: CGFloat = 50
	let buttonHeight: CGFloat = 50
	let extraSpace: CGFloat = 15
	
	var body: some View {
		let dividerWidth: CGFloat = (CGFloat(numberOfColumns) * buttonWidth) + extraSpace
		
		VStack {
			let totalSlots = numberOfColumns * numberOfRows
			let recentApps = appState.recentApps
			let paddedApps = recentApps + Array(
				repeating: ("", "", NSImage()),
				count: max(0, totalSlots - recentApps.count)
			)
			
			ForEach(0..<numberOfRows, id: \.self) { rowIndex in
				HStack(alignment: .center) {
					ForEach(0..<numberOfColumns, id: \.self) { columnIndex in
						let appIndex = (rowIndex * numberOfColumns) + columnIndex
						let (appName, bundleId, appIcon) = paddedApps[appIndex]
						
						VStack(spacing: 3) {
							ButtonView(
								appName: appName,
								bundleId: bundleId,
								appIcon: appIcon,
								buttonWidth: buttonWidth,
								buttonHeight: buttonHeight,
								isContextMenuVisible: Binding(
									get: { activeContextMenuIndex == appIndex },
									set: { isVisible in
										activeContextMenuIndex = isVisible ? appIndex : nil
									}
								),
								onRemove: {
									// Only remove if this index corresponds to a real app
									if appIndex < appState.recentApps.count {
										appState.recentApps.remove(at: appIndex)
									}
									// Clear or adjust active context menu index
									if activeContextMenuIndex == appIndex {
										activeContextMenuIndex = nil
									} else if let active = activeContextMenuIndex, active > appIndex {
										activeContextMenuIndex = active - 1
									}
								}
							)
							
							if !appName.isEmpty {
								Text(appName)
									.font(.system(size: 8))
									.lineLimit(1)
									.foregroundColor(.white)
									.padding(.horizontal, 5)
									.padding(.vertical, 2)
									.background(Color.black.opacity(0.25))
									.cornerRadius(3)
							}
						}
					}
				}
				
				// Divider between rows (except last row)
				if rowIndex < (numberOfRows - 1) {
					Divider()
						.frame(width: dividerWidth)
						.background(Color.blue)
						.padding(.vertical, 5)
				}
			}
		}
		.padding()
		// When a context menu is open, capture any tap inside the dock to dismiss it
		.overlay(
			Color.clear
				.contentShape(Rectangle())
				.allowsHitTesting(activeContextMenuIndex != nil)
				.onTapGesture { dismissContextMenus() }
		)
		.onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
			dismissContextMenus()
		}
		.onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)) { notification in
			if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
			   app.bundleIdentifier != Bundle.main.bundleIdentifier {
				dismissContextMenus()
			}
		}
		.onAppear {
			// Local monitor fires for clicks inside the app/menu
			localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { event in
				dismissContextMenus()
				return event
			}

			// Global monitor fires for clicks outside the app
			mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { _ in
				dismissContextMenus()
			}
		}
		.onDisappear {
			if let monitor = localMouseMonitor {
				NSEvent.removeMonitor(monitor)
				localMouseMonitor = nil
			}
			if let monitor = mouseMonitor {
				NSEvent.removeMonitor(monitor)
				mouseMonitor = nil
			}
		}
	}
}

//#Preview {
//    DockView(appState: .init())
//}
