import AppKit

final class MenuBarController: NSObject {
    private let statusItem: NSStatusItem
    private let controller: BoostController
    private var settingsWindow: SettingsWindowController?

    init(controller: BoostController) {
        self.controller = controller
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        if let button = statusItem.button {
            button.image = Self.menuIcon()
            button.toolTip = "Daylit"
        }

        controller.onStateChange = { [weak self] in
            self?.rebuildMenu()
            self?.settingsWindow?.refresh()
        }
        rebuildMenu()
    }

    private static func menuIcon() -> NSImage {
        if let url = Bundle.main.url(forResource: "MenuBarIcon", withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            image.isTemplate = true
            image.size = NSSize(width: 18, height: 18)
            return image
        }
        return NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: "Daylit")
            ?? NSImage()
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let status = NSMenuItem(title: statusLine(), action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)
        menu.addItem(.separator())

        let enabled = NSMenuItem(
            title: Settings.enabled ? "Boost On" : "Boost Off",
            action: #selector(toggleEnabled),
            keyEquivalent: "e"
        )
        enabled.target = self
        enabled.state = Settings.enabled ? .on : .off
        menu.addItem(enabled)

        let presets = NSMenuItem(title: "Intensity", action: nil, keyEquivalent: "")
        let presetMenu = NSMenu()
        for value in [1.2, 1.4, 1.6, 1.8, 2.0] as [Float] {
            let title = String(format: "%.1f×", value)
            let item = NSMenuItem(title: title, action: #selector(setIntensity(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = value
            if abs(Settings.boostCeiling - value) < 0.05 {
                item.state = .on
            }
            presetMenu.addItem(item)
        }
        presets.submenu = presetMenu
        menu.addItem(presets)

        menu.addItem(.separator())

        let settings = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Daylit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu
    }

    private func statusLine() -> String {
        switch controller.mode {
        case .off: return "Off"
        case .freeHalf: return "Free · half screen"
        case .full: return "Full unlock"
        case .unsupported: return "Unsupported display"
        case .waitingForAC: return "Waiting for power"
        }
    }

    @objc private func toggleEnabled() {
        Settings.enabled.toggle()
        controller.reconcile()
    }

    @objc private func setIntensity(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? Float else { return }
        Settings.boostCeiling = value
        controller.reconcile()
        rebuildMenu()
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindowController(boost: controller) { [weak self] in
                self?.rebuildMenu()
            }
        }
        settingsWindow?.show()
    }

    @objc private func quit() {
        controller.stop()
        NSApp.terminate(nil)
    }
}
