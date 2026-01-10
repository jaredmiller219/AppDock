import AppKit

final class KeyVisualizer {
    private static var window: NSWindow?
    private static var label: NSTextField?
    private static var fadeTimer: Timer?

    static func startIfRunningUITests() {
        let env = ProcessInfo.processInfo.environment
        let hasXCTest = env["XCTestConfigurationFilePath"] != nil
        let forceOn = env["SHOW_KEY_VISUALIZER"] == "1"
        guard hasXCTest || forceOn else { return }
        NSLog("KeyVisualizer: starting (hasXCTest:\(hasXCTest), forced:\(forceOn))")
        start()
    }

    static func start() {
        DispatchQueue.main.async {
            guard window == nil else { return }

            let content = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 56))
            content.wantsLayer = true
            content.layer?.cornerRadius = 8
            content.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.55).cgColor

            let lbl = NSTextField(labelWithString: "")
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.font = .monospacedSystemFont(ofSize: 20, weight: .bold)
            lbl.textColor = .white
            lbl.alignment = .center
            content.addSubview(lbl)
            NSLayoutConstraint.activate([
                lbl.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 8),
                lbl.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -8),
                lbl.centerYAnchor.constraint(equalTo: content.centerYAnchor)
            ])

            let win = NSWindow(
                contentRect: NSRect(x: 20, y: 40, width: 320, height: 56),
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            win.isOpaque = false
            win.backgroundColor = .clear
            win.level = .statusBar
            win.ignoresMouseEvents = true
            win.hasShadow = true
            win.contentView = content
            win.collectionBehavior = [.canJoinAllSpaces, .stationary]
            win.makeKeyAndOrderFront(nil)

            window = win
            label = lbl

            NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
                handle(event: event)
                return event
            }
        }
    }

    private static func handle(event: NSEvent) {
        let chars = (event.charactersIgnoringModifiers ?? event.characters) ?? ""
        var parts: [String] = []
        let flags = event.modifierFlags
        if flags.contains(.command) { parts.append("⌘") }
        if flags.contains(.option)  { parts.append("⌥") }
        if flags.contains(.control) { parts.append("⌃") }
        if flags.contains(.shift)   { parts.append("⇧") }
        if !chars.isEmpty { parts.append(chars.uppercased()) }
        show(parts.joined())
    }

    private static func show(_ displayText: String) {
        DispatchQueue.main.async {
            guard let lbl = label else { return }
            lbl.stringValue = displayText
            lbl.alphaValue = 1
            fadeTimer?.invalidate()
            fadeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                NSAnimationContext.runAnimationGroup({ ctx in
                    ctx.duration = 0.25
                    lbl.animator().alphaValue = 0
                }, completionHandler: nil)
            }
        }
    }
}
