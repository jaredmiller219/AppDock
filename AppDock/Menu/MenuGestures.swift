//
//  MenuGestures.swift
//  AppDock
//

import SwiftUI
import AppKit

enum SwipeDirection {
    case left
    case right
}

struct SwipeGestureCaptureView: NSViewRepresentable {
    let swipeThreshold: CGFloat
    let onSwipe: (SwipeDirection) -> Void
    let onScrollChanged: (CGFloat, CGFloat) -> Void
    let onScrollEnded: (CGFloat, CGFloat) -> Void

    func makeNSView(context: Context) -> SwipeCaptureNSView {
        let view = SwipeCaptureNSView()
        view.swipeThreshold = swipeThreshold
        view.onSwipe = onSwipe
        view.onScrollChanged = onScrollChanged
        view.onScrollEnded = onScrollEnded
        return view
    }

    func updateNSView(_ nsView: SwipeCaptureNSView, context: Context) {
        nsView.swipeThreshold = swipeThreshold
        nsView.onSwipe = onSwipe
        nsView.onScrollChanged = onScrollChanged
        nsView.onScrollEnded = onScrollEnded
    }

    final class SwipeCaptureNSView: NSView {
        var onSwipe: ((SwipeDirection) -> Void)?
        var onScrollChanged: ((CGFloat, CGFloat) -> Void)?
        var onScrollEnded: ((CGFloat, CGFloat) -> Void)?
        var swipeThreshold: CGFloat = 50
        private var scrollMonitor: Any?
        private var accumulatedX: CGFloat = 0
        private var accumulatedY: CGFloat = 0
        private var isTracking = false

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            wantsLayer = true
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if scrollMonitor == nil {
                scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
                    guard let self else { return event }
                    guard self.window === event.window else { return event }
                    let location = self.convert(event.locationInWindow, from: nil)
                    guard self.bounds.contains(location) else { return event }
                    self.handleScrollEvent(event)
                    return event
                }
            }
        }

        deinit {
            if let scrollMonitor {
                NSEvent.removeMonitor(scrollMonitor)
            }
        }

        override func swipe(with event: NSEvent) {
            if event.deltaX > 0 {
                onSwipe?(.right)
            } else if event.deltaX < 0 {
                onSwipe?(.left)
            }
        }

        private func handleScrollEvent(_ event: NSEvent) {
            let isFingerEvent = !event.phase.isEmpty

            if event.phase == .began {
                accumulatedX = 0
                accumulatedY = 0
                isTracking = true
            }

            if isFingerEvent && !isTracking && event.phase == .changed {
                isTracking = true
            }

            if isFingerEvent {
                accumulatedX += event.scrollingDeltaX
                accumulatedY += event.scrollingDeltaY
                onScrollChanged?(accumulatedX, accumulatedY)
            }

            if event.phase == .ended || event.phase == .cancelled {
                if isTracking {
                    onScrollEnded?(accumulatedX, accumulatedY)
                }
                accumulatedX = 0
                accumulatedY = 0
                isTracking = false
            }
        }
    }
}
