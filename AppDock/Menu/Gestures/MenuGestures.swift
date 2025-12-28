//
//  MenuGestures.swift
//  AppDock
//
/*
 MenuGestures.swift

 Purpose:
  - Provide a small interop layer between AppKit's gesture/scroll events and
    SwiftUI so the popover can support trackpad swipe gestures and drag
    interactions for paging between menu pages.

 Overview:
  - `SwipeGestureCaptureView` wraps an `NSView` that monitors `swipe` and
    `scrollWheel` events and reports aggregated deltas to SwiftUI.
  - The implementation isolates platform details so the SwiftUI layer can
    react to high-level gestures without direct NSEvent handling.
*/

import AppKit
import SwiftUI

/// Direction of a recognized swipe gesture.
enum SwipeDirection {
    case left
    case right
}

/// Bridge view that captures native swipe/scroll events and forwards them
/// as higher-level callbacks used by the popover interactive swipe logic.
struct SwipeGestureCaptureView: NSViewRepresentable {
    let swipeThreshold: CGFloat
    let onSwipe: (SwipeDirection) -> Void
    let onScrollChanged: (CGFloat, CGFloat) -> Void
    let onScrollEnded: (CGFloat, CGFloat) -> Void

    func makeNSView(context _: Context) -> SwipeCaptureNSView {
        let view = SwipeCaptureNSView()
        view.swipeThreshold = swipeThreshold
        view.onSwipe = onSwipe
        view.onScrollChanged = onScrollChanged
        view.onScrollEnded = onScrollEnded
        return view
    }

    func updateNSView(_ nsView: SwipeCaptureNSView, context _: Context) {
        nsView.swipeThreshold = swipeThreshold
        nsView.onSwipe = onSwipe
        nsView.onScrollChanged = onScrollChanged
        nsView.onScrollEnded = onScrollEnded
    }

    /// Native NSView subclass that monitors platform events (swipe/scroll)
    /// and translates them into higher-level gesture callbacks for SwiftUI.
    final class SwipeCaptureNSView: NSView {
        /// Callback invoked when a swipe gesture is recognized.
        var onSwipe: ((SwipeDirection) -> Void)?

        /// Callback invoked as scroll deltas accumulate during a trackpad drag.
        var onScrollChanged: ((CGFloat, CGFloat) -> Void)?

        /// Callback invoked when a scroll/drag sequence ends or is cancelled.
        var onScrollEnded: ((CGFloat, CGFloat) -> Void)?

        /// Minimum horizontal distance required to trigger a snap swipe (not used for dragging).
        var swipeThreshold: CGFloat = 50

        /// Reference to the installed scroll event monitor (cleaned up in deinit).
        private var scrollMonitor: Any?

        /// Accumulated horizontal delta from the start of the current drag.
        private var accumulatedX: CGFloat = 0

        /// Accumulated vertical delta from the start of the current drag.
        private var accumulatedY: CGFloat = 0

        /// Flag indicating whether we are currently tracking a drag sequence.
        private var isTracking = false

        /// Initialize the swipe capture view with the given frame.
        /// - Parameter frameRect: The initial frame for the view.
        /// - Note: Sets `wantsLayer = true` to enable layer-backed rendering.
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            // Enable layer-backed rendering for proper event handling.
            wantsLayer = true
        }

        /// Initialize from a storyboard or xib file.
        /// - Parameter coder: The decoder used to unarchive the view.
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            // Enable layer-backed rendering for proper event handling.
            wantsLayer = true
        }

        /// Called when the view is added to a window; installs scroll event monitoring.
        /// - Note: Ensures we only install one monitor per view lifecycle.
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            // Install the scroll event monitor only once.
            if scrollMonitor == nil {
                // Monitor local scroll events when the view is attached so we
                // can translate them into interactive drag deltas for SwiftUI.
                scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
                    // Avoid retain cycles by using weak self.
                    guard let self else { return event }
                    // Only handle events from this view's window.
                    guard self.window === event.window else { return event }
                    // Convert the event location to this view's coordinate system.
                    let location = self.convert(event.locationInWindow, from: nil)
                    // Only process the event if it occurred within this view's bounds.
                    guard self.bounds.contains(location) else { return event }
                    // Delegate to the main event handler.
                    self.handleScrollEvent(event)
                    // Return the event so other handlers can also process it.
                    return event
                }
            }
        }

        /// Cleanup: remove the scroll event monitor to avoid memory leaks.
        deinit {
            if let scrollMonitor {
                // Uninstall the scroll monitor when the view is deallocated.
                NSEvent.removeMonitor(scrollMonitor)
            }
        }

        /// Called by AppKit when a swipe gesture is detected.
        /// - Parameter event: The swipe event with deltaX indicating direction.
        /// - Note: Reports only the direction, not distance.
        override func swipe(with event: NSEvent) {
            // Check the horizontal delta to determine swipe direction.
            if event.deltaX > 0 {
                // Rightward swipe.
                onSwipe?(.right)
            } else if event.deltaX < 0 {
                // Leftward swipe.
                onSwipe?(.left)
            }
        }

        /// Called by AppKit when a scroll wheel or trackpad scroll event is detected.
        /// - Parameter event: The scroll event with deltaX/deltaY and phase info.
        override func scrollWheel(with event: NSEvent) {
            // Process the scroll event into accumulated drag deltas.
            handleScrollEvent(event)
            // Call the superclass implementation to allow event propagation.
            super.scrollWheel(with: event)
        }

        /// Internal method that translates NSEvent scroll deltas into SwiftUI callbacks.
        ///
        /// - Parameter event: The scroll wheel event from AppKit.
        /// - Note: Handles both real trackpad finger events and synthetic UI test events,
        ///   accumulating deltas across the lifetime of a trackpad drag sequence.
        private func handleScrollEvent(_ event: NSEvent) {
            // Determine if this is a real finger event (has phase info) vs synthetic.
            let isFingerEvent = !event.phase.isEmpty

            // UI test mode: treat non-finger events as immediate changed/ended sequences.
            if !isFingerEvent,
               event.momentumPhase.isEmpty,
               ProcessInfo.processInfo.arguments.contains(AppDockConstants.Testing.uiTestMode)
            {
                let deltaX = event.scrollingDeltaX
                let deltaY = event.scrollingDeltaY
                // Only report if there was actual movement.
                guard deltaX != 0 || deltaY != 0 else { return }
                // Report the change immediately.
                onScrollChanged?(deltaX, deltaY)
                // End the sequence immediately (synchronous for testing).
                onScrollEnded?(deltaX, deltaY)
                return
            }

            // Real trackpad: detect the start of a new drag sequence.
            if event.phase == .began {
                // Reset accumulators at the start of a new sequence.
                accumulatedX = 0
                accumulatedY = 0
                isTracking = true
            }

            // Detect when trackpad becomes active mid-sequence.
            if isFingerEvent && !isTracking && event.phase == .changed {
                isTracking = true
            }

            // Accumulate deltas while the finger is on the trackpad.
            if isFingerEvent {
                accumulatedX += event.scrollingDeltaX
                accumulatedY += event.scrollingDeltaY
                // Report accumulated progress to SwiftUI.
                onScrollChanged?(accumulatedX, accumulatedY)
            }

            // UI test mode: report end when momentum phase is idle (indicates held gesture end).
            if isFingerEvent,
               event.phase == .changed,
               event.momentumPhase.isEmpty,
               ProcessInfo.processInfo.arguments.contains(AppDockConstants.Testing.uiTestMode)
            {
                onScrollEnded?(accumulatedX, accumulatedY)
                // Reset for the next sequence.
                accumulatedX = 0
                accumulatedY = 0
                isTracking = false
            }

            // Real trackpad: detect the end or cancellation of the drag sequence.
            if event.phase == .ended || event.phase == .cancelled {
                if isTracking {
                    // Report the final accumulated delta.
                    onScrollEnded?(accumulatedX, accumulatedY)
                }
                // Reset for the next sequence.
                accumulatedX = 0
                accumulatedY = 0
                isTracking = false
            }
        }
    }
}
