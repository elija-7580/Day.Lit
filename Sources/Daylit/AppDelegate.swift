import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var boost: BoostController?
    private var menuBar: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = BoostController()
        boost = controller
        menuBar = MenuBarController(controller: controller)
        controller.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        boost?.stop()
    }
}
