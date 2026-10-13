import AppKit
import Combine

final class MenuBarController: NSObject {
    private let statusItem: NSStatusItem
    private let boost: BoostController
    private weak var mainWindow: MainWindowController?
    private var cancellables = Set<AnyCancellable>()

    init(boost: BoostController, mainWindow: MainWindowController) {
        self.boost = boost
        self.mainWindow = mainWindow
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
        // Prefer system SF Symbol so menu bar always matches macOS rendering.
        if let image = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: "Day.Lit") {
            let configured = image.withSymbolConfiguration(
                .init(pointSize: 14, weight: .medium)
            ) ?? image
            configured.isTemplate = true
            return configured
        }
        if let url = Bundle.main.url(forResource: "MenuBarIcon", withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            image.isTemplate = true
            image.size = NSSize(width: 18, height: 18)
            return image
        }
        return NSImage()
    }

    private func updateTooltip() {
        statusItem.button?.toolTip = "Day.Lit — \(boost.statusText)"
    }

    @objc private func statusClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            openApp()
            return
        }
        if event.type == .rightMouseUp {
            statusItem.menu = buildMenu()
            statusItem.button?.performClick(nil)
            DispatchQueue.main.async { [weak self] in
                self?.statusItem.menu = nil
            }
        } else {
            openApp()
        }
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let status = NSMenuItem(title: boost.statusText, action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)
        menu.addItem(.separator())

        let enabled = NSMenuItem(
            title: boost.enabled ? "Boost On" : "Boost Off",
            action: #selector(toggleEnabled),
            keyEquivalent: "e"
        )
        enabled.target = self
        enabled.state = boost.enabled ? .on : .off
        menu.addItem(enabled)

        let sliderItem = NSMenuItem()
        let slider = NSSlider(
            value: Double(boost.boostCeiling),
            minValue: 1.0,
            maxValue: 2.0,
            target: self,
            action: #selector(sliderChanged(_:))
        )
        slider.isContinuous = true
        slider.frame = NSRect(x: 14, y: 6, width: 200, height: 28)
        let wrap = NSView(frame: NSRect(x: 0, y: 0, width: 228, height: 40))
        wrap.addSubview(slider)
        sliderItem.view = wrap
        menu.addItem(sliderItem)

        menu.addItem(.separator())
        let open = NSMenuItem(title: "Open Day.Lit", action: #selector(openApp), keyEquivalent: "o")
        open.target = self
        menu.addItem(open)

        let quit = NSMenuItem(title: "Quit Day.Lit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        return menu
    }

    @objc private func toggleEnabled() {
        boost.enabled.toggle()
    }

    @objc private func sliderChanged(_ sender: NSSlider) {
        boost.boostCeiling = Float(sender.doubleValue)
    }

    @objc private func openApp() {
        mainWindow?.show()
    }

    @objc private func quit() {
        boost.stop()
        NSApp.terminate(nil)
    }
}
