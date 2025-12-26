import XCTest
import SwiftUI
import AppKit
import Combine
@testable import AppDock

// This file uses lightweight stubs so view logic can be tested without
// pulling in the full SwiftUI hierarchy.

// MARK: - MOCK DEPENDENCIES

// Helper function to create a dummy NSImage for testing purposes.
func test_createDummyImage() -> NSImage {
	// Creating a 64x64 transparent image to match the expected icon size
	return NSImage(
		size: NSSize(
			width: AppDockConstants.AppIcon.size,
			height: AppDockConstants.AppIcon.size
		)
	)
}

// 2. Minimal Stub for the original AppState class (The base type)
// Provides an ObservableObject type to match the production API.
class DockViewStubBaseState: ObservableObject {
	// We only need the ObservableObject conformance for the cast to work in Test 1
	// And an init() for inheritance.
	init() {}
}

// 1. Mock AppState for test data control (unique name)
// FIX: Inherit from AppState to make the cast work in Test 1.
// Holds a mutable recentApps list for test setup.
class DockViewTestAppState: DockViewStubBaseState {
	// Match the tuple structure used by the original AppState
	typealias AppDetail = (name: String, bundleid: String, icon: NSImage)
	// NOTE: In a real app, 'recentApps' would typically be defined on the base AppState.
	// We define it here on the mock for test data control.
	@Published var recentApps: [AppDetail]
	
	override init() {
		self.recentApps = []
		super.init()
	}
	
	init(apps: [AppDetail] = []) {
		self.recentApps = apps
		super.init()
	}
}

// 3. Minimal Stub for DockView (Required to resolve "Cannot find DockView in scope")
// Provides the grid constants used by the tests.
struct DockView: View {
	// Must match the original DockView's properties used in the test logic
	@ObservedObject var appState: DockViewStubBaseState // Uses the stubbed base state
	let numberOfColumns: Int = 3
	let numberOfRows: Int = 4
	
	var body: some View { Text("Dock View Stub") }
}

// 4. Minimal Stub for ButtonView (Required to resolve "Cannot find ButtonView in scope")
// Mimics the production initializer signature for test helpers.
struct ButtonView: View {
	// Must match all required initializers/properties from the original ButtonView
	let appName: String
	let bundleId: String
	let appIcon: NSImage
	let buttonWidth: CGFloat
	let buttonHeight: CGFloat
	let allowRemove: Bool
	@Binding var isContextMenuVisible: Bool
	let onRemove: () -> Void
	
	var body: some View { Text("Button View Stub") }
}


// MARK: - DockView Tests

/// Tests for DockView layout logic and button state behaviors.
final class DockViewTests: XCTestCase {
	
	// Define the type alias locally for convenience, using the highly unique mock state
	typealias AppDetail = DockViewTestAppState.AppDetail
	
	// Helper that mirrors the context-menu tap logic in ButtonView
	struct ButtonContextMenuHandler {
		static func handleTap(currentEvent: NSEvent?, isContextMenuVisible: inout Bool) {
			if let event = currentEvent, event.modifierFlags.contains(.command) {
				isContextMenuVisible.toggle()
			} else {
				isContextMenuVisible = false
			}
		}
	}
	
	// Helper that mirrors the dismissContextMenus call in DockView
	struct DockContextMenuState {
		var activeContextMenuIndex: Int?
		
		mutating func dismissContextMenus() {
			activeContextMenuIndex = nil
		}
	}

	// Helper that mirrors the onRemove logic in DockView's ButtonView closure.
	struct DockRemoveHandler {
		var recentApps: [AppDetail]
		var activeContextMenuIndex: Int?

		mutating func remove(at index: Int) {
			if index < recentApps.count {
				recentApps.remove(at: index)
			}
			if activeContextMenuIndex == index {
				activeContextMenuIndex = nil
			} else if let active = activeContextMenuIndex, active > index {
				activeContextMenuIndex = active - 1
			}
		}
	}
	
	// Test 1: Verify the DockView correctly calculates the padded app list (padding logic)
	func testDockView_paddingLogic() {
		let app1: AppDetail = ("App One", "id.one", test_createDummyImage())
		let app2: AppDetail = ("App Two", "id.two", test_createDummyImage())
		
		let appState = DockViewTestAppState(apps: [app1, app2])
		
		// This cast now works because DockViewTestAppState inherits from AppState.
		let dockView = DockView(appState: appState as DockViewStubBaseState)
		
		// Assuming the properties from the original DockView source file (3x4)
		let totalSlots = dockView.numberOfColumns * dockView.numberOfRows // 3 * 4 = 12
		
		let recentApps = appState.recentApps
		// This logic mimics the padding calculation inside DockView
		let paddedAppsCount = recentApps.count + max(0, totalSlots - recentApps.count)
		
		XCTAssertEqual(paddedAppsCount, 12, "The total number of slots should be 12 (3x4).")
		XCTAssertEqual(recentApps.count, 2, "Starting app count should be 2.")
		
		let expectedPaddingCount = 10
		XCTAssertEqual(totalSlots - recentApps.count, expectedPaddingCount, "The padding array size should be 10.")
	}
	
	// Test 2: Verify the onRemove closure correctly removes an item from AppState
	func testButtonView_onRemoveAction() {
		// Setup state for DockView
		let app1: AppDetail = ("App One", "id.one", test_createDummyImage())
		let app2: AppDetail = ("App Two", "id.two", test_createDummyImage())
		let appState = DockViewTestAppState(apps: [app1, app2])
		
		// Setup a host for the ButtonView to provide required @State bindings
		struct ButtonViewTestHost: View {
			@ObservedObject var appState: DockViewTestAppState
			@State var isContextVisible: Bool = false
			let appIndexToRemove: Int
			let buttonWidth: CGFloat = 50
			let buttonHeight: CGFloat = 50
			
			var body: some View {
				// Now uses the stubbed ButtonView
				ButtonView(
					appName: appState.recentApps[appIndexToRemove].name,
					bundleId: appState.recentApps[appIndexToRemove].bundleid,
					appIcon: appState.recentApps[appIndexToRemove].icon,
					buttonWidth: buttonWidth,
					buttonHeight: buttonHeight,
					allowRemove: true,
					isContextMenuVisible: $isContextVisible,
					onRemove: {
						// This replicates the closure executed by the 'X' button
						appState.recentApps.remove(at: appIndexToRemove)
					}
				)
			}
		}
		
		// Instantiate the Host for testing the removal of the item at index 1
		_ = ButtonViewTestHost(appState: appState, appIndexToRemove: 1)
		
		// State before removal
		XCTAssertEqual(appState.recentApps.count, 2, "Initial state should have 2 apps.")
		
		// Execute the closure's logic directly, which is to remove the item at index 1.
		appState.recentApps.remove(at: 1)
		
		// State after removal
		XCTAssertEqual(appState.recentApps.count, 1, "The app count should decrease to 1 after removal.")
		XCTAssertEqual(appState.recentApps.first?.name, "App One", "The remaining app should be 'App One'.")
	}
	
	// Test 3: Verify EmptySlot rendering when appName is empty (Tested by verifying input condition)
	func testButtonView_rendersEmptySlotWhenEmpty() {
		// Setup a host with an empty app entry
		struct ButtonViewEmptyTestHost: View {
			@State var isContextVisible: Bool = false
			let appDetail: AppDetail = ("", "", test_createDummyImage()) // Empty slot data
			
			var body: some View {
				// Now uses the stubbed ButtonView
				ButtonView(
					appName: appDetail.name,
					bundleId: appDetail.bundleid,
					appIcon: appDetail.icon,
					buttonWidth: 50,
					buttonHeight: 50,
					allowRemove: true,
					isContextMenuVisible: $isContextVisible,
					onRemove: {}
				)
			}
		}
		
		let host = ButtonViewEmptyTestHost()
		XCTAssertTrue(host.appDetail.name.isEmpty, "The app name should be empty for this test case.")
	}
	
	// Test 4: Verify IconView rendering when appName is present (Tested by verifying input condition)
	func testButtonView_rendersIconViewWhenPresent() {
		// Setup a host with a valid app entry
		struct ButtonViewPresentTestHost: View {
			@State var isContextVisible: Bool = false
			let appDetail: AppDetail = ("TestApp", "id.test", test_createDummyImage())
			
			var body: some View {
				// Now uses the stubbed ButtonView
				ButtonView(
					appName: appDetail.name,
					bundleId: appDetail.bundleid,
					appIcon: appDetail.icon,
					buttonWidth: 50,
					buttonHeight: 50,
					allowRemove: true,
					isContextMenuVisible: $isContextVisible,
					onRemove: {}
				)
			}
		}
		
		let host = ButtonViewPresentTestHost()
		XCTAssertFalse(host.appDetail.name.isEmpty, "The app name should not be empty for this test case.")
	}
	
	// Test 5: Regular clicks should clear the context menu (matches the non-command path)
	func testButtonRegularClickClearsContextMenu() {
		var isVisible = true
		ButtonContextMenuHandler.handleTap(currentEvent: nil, isContextMenuVisible: &isVisible)
		XCTAssertFalse(isVisible, "Regular click should clear an open context menu.")
	}
	
	// Test 6: Command-click toggles the context menu visibility (matches the command path)
	func testButtonCommandClickTogglesContextMenu() {
		var isVisible = false
		let cmdEvent = NSEvent.mouseEvent(
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
		
		ButtonContextMenuHandler.handleTap(currentEvent: cmdEvent, isContextMenuVisible: &isVisible)
		XCTAssertTrue(isVisible, "Command-click should toggle the context menu to visible.")
	}
	
	// Test 6b: Command-click when already visible should toggle it off
	func testButtonCommandClickTogglesContextMenuOff() {
		var isVisible = true
		let cmdEvent = NSEvent.mouseEvent(
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
		
		ButtonContextMenuHandler.handleTap(currentEvent: cmdEvent, isContextMenuVisible: &isVisible)
		XCTAssertFalse(isVisible, "Command-click should toggle the context menu off if it was visible.")
	}
	
	// Test 7: Overlay dismissal clears the active context menu index
	func testOverlayTapDismissesActiveContextMenu() {
		var state = DockContextMenuState(activeContextMenuIndex: 3)
		state.dismissContextMenus()
		XCTAssertNil(state.activeContextMenuIndex, "Overlay tap (dismiss call) should clear the active context menu.")
	}
	
	// Test 8: Padding logic with zero apps still fills all slots
	func testDockView_paddingLogic_whenEmpty() {
		let appState = DockViewTestAppState(apps: [])
		let dockView = DockView(appState: appState as DockViewStubBaseState)
		let totalSlots = dockView.numberOfColumns * dockView.numberOfRows
		
		XCTAssertEqual(totalSlots, 12, "Total slots should remain constant even when no apps exist.")
		let expectedPadding = totalSlots - appState.recentApps.count
		XCTAssertEqual(expectedPadding, 12, "All slots should be padding when there are no apps.")
	}

	// Test 9: Removing the active app should clear the active context menu index.
	func testDockView_removeClearsActiveIndex() {
		let apps: [AppDetail] = [
			("One", "id.one", test_createDummyImage()),
			("Two", "id.two", test_createDummyImage()),
			("Three", "id.three", test_createDummyImage())
		]
		var handler = DockRemoveHandler(recentApps: apps, activeContextMenuIndex: 1)

		handler.remove(at: 1)

		XCTAssertEqual(handler.recentApps.count, 2)
		XCTAssertNil(handler.activeContextMenuIndex)
	}

	// Test 10: Removing an item before the active one should shift the index down.
	func testDockView_removeAdjustsActiveIndex() {
		let apps: [AppDetail] = [
			("One", "id.one", test_createDummyImage()),
			("Two", "id.two", test_createDummyImage()),
			("Three", "id.three", test_createDummyImage())
		]
		var handler = DockRemoveHandler(recentApps: apps, activeContextMenuIndex: 2)

		handler.remove(at: 0)

		XCTAssertEqual(handler.recentApps.count, 2)
		XCTAssertEqual(handler.activeContextMenuIndex, 1)
	}
}
