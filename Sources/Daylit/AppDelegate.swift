import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var boost: BoostController!
    private var panel: PanelController!
    private var menuBar: MenuBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        applyActivationPolicy()

        let controller = BoostController()
        boost = controller
        panel = PanelController(boost: controller)
        menuBar = MenuBarController(boost: controller, panel: panel)
        controller.onDockIconChange = { [weak self] in
            self?.applyActivationPolicy()
        }
        controller.start()
        // Stay in the menu bar until the user opens the panel.
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Dock click / Finder reopen → show panel.
        menuBar?.showPanel()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        boost?.stop()
    }

    private func applyActivationPolicy() {
        NSApp.setActivationPolicy(Settings.showDockIcon ? .regular : .accessory)
    }
}
