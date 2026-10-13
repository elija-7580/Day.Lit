import Foundation

enum Settings {
    private static let defaults = UserDefaults.standard

    static var enabled: Bool {
        get { defaults.object(forKey: "enabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "enabled") }
    }

    /// 1.0 = no boost, 2.0 ≈ 2× headroom.
    static var boostCeiling: Float {
        get {
            let value = defaults.object(forKey: "boostCeiling") as? Float ?? 1.6
            return min(max(value, 1.0), 2.0)
        }
        set { defaults.set(min(max(newValue, 1.0), 2.0), forKey: "boostCeiling") }
    }

    static var acOnly: Bool {
        get { defaults.object(forKey: "acOnly") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "acOnly") }
    }

    static var launchAtLogin: Bool {
        get { defaults.object(forKey: "launchAtLogin") as? Bool ?? false }
        set { defaults.set(newValue, forKey: "launchAtLogin") }
    }

    /// Menu bar by default; Dock icon is optional.
    static var showDockIcon: Bool {
        get { defaults.object(forKey: "showDockIcon") as? Bool ?? false }
        set { defaults.set(newValue, forKey: "showDockIcon") }
    }
}
