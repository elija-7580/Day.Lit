import Foundation
import ServiceManagement

enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    @discardableResult
    static func setEnabled(_ enabled: Bool) -> Bool {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            Settings.launchAtLogin = enabled
            return true
        } catch {
            return false
        }
    }

    static func syncFromSystem() {
        Settings.launchAtLogin = isEnabled
    }
}
