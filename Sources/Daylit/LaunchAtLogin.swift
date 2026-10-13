import Foundation
import ServiceManagement

enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    @discardableResult
    static func setEnabled(_ enabled: Bool) -> Bool {
        // No-op if already in the requested state.
        if enabled == isEnabled {
            Settings.launchAtLogin = enabled
            return true
        }

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            Settings.launchAtLogin = isEnabled
            return true
        } catch {
            Settings.launchAtLogin = isEnabled
            return false
        }
    }

    static func syncFromSystem() {
        Settings.launchAtLogin = isEnabled
    }
}
