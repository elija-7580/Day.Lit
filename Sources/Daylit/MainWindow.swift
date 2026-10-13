import AppKit
import SwiftUI

final class MainWindowController: NSWindowController {
    init(boost: BoostController) {
        let hosting = NSHostingController(rootView: ContentView(boost: boost))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 420),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Day.Lit"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.contentViewController = hosting
        window.center()
        window.setFrameAutosaveName("DayLitMain")
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.hasShadow = true
        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func show() {
        NSApp.setActivationPolicy(.regular)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
