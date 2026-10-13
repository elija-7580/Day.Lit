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
            button.sendAction(on: [.leftMouseUp])
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
        panel.toggle(relativeTo: statusItem.button)
    }
}
