import AppKit
import SwiftUI

/// Floating panel anchored under the menu bar icon (Scratchpad-style).
final class PanelController: NSWindowController, NSWindowDelegate {
    private let boost: BoostController

    var isVisible: Bool {
        window?.isVisible == true
    }

    init(boost: BoostController) {
        self.boost = boost

        let hosting = NSHostingController(rootView: ContentView(boost: boost))
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 400),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.title = "Day.Lit"
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.contentViewController = hosting
        panel.setContentSize(NSSize(width: 320, height: 400))

        super.init(window: panel)
        panel.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func toggle(relativeTo statusButton: NSStatusBarButton?) {
        if isVisible {
            hide()
        } else {
            show(relativeTo: statusButton)
        }
    }

    func show(relativeTo statusButton: NSStatusBarButton?) {
        guard let panel = window else { return }
        position(panel, relativeTo: statusButton)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        window?.orderOut(nil)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hide()
        return false
    }

    private func position(_ panel: NSWindow, relativeTo statusButton: NSStatusBarButton?) {
        let size = panel.frame.size
        var origin = NSPoint.zero

        if let button = statusButton,
           let buttonWindow = button.window {
            let buttonFrame = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
            origin = NSPoint(
                x: buttonFrame.midX - size.width / 2,
                y: buttonFrame.minY - size.height - 8
            )
            if let screen = buttonWindow.screen ?? NSScreen.main {
                let visible = screen.visibleFrame
                origin.x = min(max(origin.x, visible.minX + 8), visible.maxX - size.width - 8)
                origin.y = min(max(origin.y, visible.minY + 8), visible.maxY - size.height - 8)
            }
        } else if let screen = NSScreen.main {
            let visible = screen.visibleFrame
            origin = NSPoint(
                x: visible.midX - size.width / 2,
                y: visible.maxY - size.height - 40
            )
        }

        panel.setFrame(NSRect(origin: origin, size: size), display: true)
    }
}
