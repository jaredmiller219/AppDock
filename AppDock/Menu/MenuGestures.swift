//
//  MenuGestures.swift
//  AppDock
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

enum SwipeDirection {
    case left
    case right
}

#if canImport(AppKit)
struct SwipeGestureCaptureView: NSViewRepresentable {
    let swipeThreshold: CGFloat
    let onSwipe: (SwipeDirection) -> Void

    func makeNSView(context: Context) -> SwipeCaptureNSView {
        let view = SwipeCaptureNSView()
        view.swipeThreshold = swipeThreshold
        view.onSwipe = onSwipe
        return view
    }

    func updateNSView(_ nsView: SwipeCaptureNSView, context: Context) {
        nsView.swipeThreshold = swipeThreshold
        nsView.onSwipe = onSwipe
    }

    final class SwipeCaptureNSView: NSView {
        var onSwipe: ((SwipeDirection) -> Void)?
        var swipeThreshold: CGFloat = 50
        private var scrollMonitor: Any?
        private var accumulatedX: CGFloat = 0
        private var accumulatedY: CGFloat = 0
        private var didTrigger = false

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
                didTrigger = true
                onSwipe?(.right)
            } else if event.deltaX < 0 {
                didTrigger = true
                onSwipe?(.left)
            }
        }

        private func handleScrollEvent(_ event: NSEvent) {
            if event.phase == .began {
                accumulatedX = 0
                accumulatedY = 0
                didTrigger = false
            }

            accumulatedX += event.scrollingDeltaX
            accumulatedY += event.scrollingDeltaY

            if !didTrigger,
               abs(accumulatedX) > abs(accumulatedY),
               abs(accumulatedX) >= swipeThreshold {
                didTrigger = true
                onSwipe?(accumulatedX < 0 ? .left : .right)
            }

            if (event.phase == .ended || event.phase == .cancelled),
               (event.momentumPhase == .ended || event.momentumPhase == .none) {
                accumulatedX = 0
                accumulatedY = 0
                didTrigger = false
            }
        }
    }
}
#elseif canImport(UIKit)
struct SwipeGestureCaptureView: UIViewRepresentable {
    let swipeThreshold: CGFloat
    let onSwipe: (SwipeDirection) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSwipe: onSwipe)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let leftSwipe = UISwipeGestureRecognizer(target: context.coordinator,
                                                 action: #selector(Coordinator.handleSwipe(_:)))
        leftSwipe.direction = .left
        let rightSwipe = UISwipeGestureRecognizer(target: context.coordinator,
                                                  action: #selector(Coordinator.handleSwipe(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        _ = swipeThreshold
    }

    final class Coordinator: NSObject {
        private let onSwipe: (SwipeDirection) -> Void

        init(onSwipe: @escaping (SwipeDirection) -> Void) {
            self.onSwipe = onSwipe
        }

        @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
            switch gesture.direction {
            case .left:
                onSwipe(.left)
            case .right:
                onSwipe(.right)
            default:
                break
            }
        }
    }
}
#endif
