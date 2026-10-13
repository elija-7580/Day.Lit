import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var boost: BoostController!
    private var mainWindow: MainWindowController!
    private var menuBar: MenuBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)

        let controller = BoostController()
        boost = controller
        mainWindow = MainWindowController(boost: controller)
        menuBar = MenuBarController(boost: controller, mainWindow: mainWindow)
        controller.start()
        mainWindow.show()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            mainWindow.show()
        }
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        boost?.stop()
    }
}
