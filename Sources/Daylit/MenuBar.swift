import AppKit
import Combine

final class MenuBarController: NSObject {
    private let statusItem: NSStatusItem
    private let boost: BoostController
    private let panel: PanelController
    private var cancellables = Set<AnyCancellable>()

    init(boost: BoostController, panel: PanelController) {
        self.boost = boost
        self.panel = panel
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        if let button = statusItem.button {
            button.image = Self.menuIcon()
            button.toolTip = "Day.Lit"
            button.target = self
            button.action = #selector(statusClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        boost.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateTooltip()
            }
            .store(in: &cancellables)

        updateTooltip()
    }

    private static func menuIcon() -> NSImage {
        if let image = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: "Day.Lit") {
            let configured = image.withSymbolConfiguration(
                .init(pointSize: 14, weight: .medium)
            ) ?? image
            configured.isTemplate = true
            return configured
        }
        return NSImage()
    }

    private func updateTooltip() {
        statusItem.button?.toolTip = "Day.Lit — \(boost.statusText)"
    }

    func showPanel() {
        panel.show(relativeTo: statusItem.button)
    }

    @objc private func statusClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            panel.toggle(relativeTo: statusItem.button)
            return
        }

        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            statusItem.menu = buildMenu()
            statusItem.button?.performClick(nil)
            DispatchQueue.main.async { [weak self] in
                self?.statusItem.menu = nil
            }
        } else {
            panel.toggle(relativeTo: statusItem.button)
        }
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let status = NSMenuItem(title: boost.statusText, action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)
        menu.addItem(.separator())

        let open = NSMenuItem(
            title: panel.isVisible ? "Hide Day.Lit" : "Open Day.Lit",
            action: #selector(togglePanel),
            keyEquivalent: "o"
        )
        open.target = self
        menu.addItem(open)

        let enabled = NSMenuItem(
            title: boost.enabled ? "Boost On" : "Boost Off",
            action: #selector(toggleEnabled),
            keyEquivalent: "e"
        )
        enabled.target = self
        enabled.state = boost.enabled ? .on : .off
        menu.addItem(enabled)

        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Day.Lit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        return menu
    }

    @objc private func togglePanel() {
        panel.toggle(relativeTo: statusItem.button)
    }

    @objc private func toggleEnabled() {
        boost.enabled.toggle()
    }

    @objc private func quit() {
        boost.stop()
        NSApp.terminate(nil)
    }
}
