import Foundation

enum FreeHalfSide: String {
    case left
    case right
}

enum Settings {
    private static let defaults = UserDefaults.standard

    static var enabled: Bool {
        get { defaults.object(forKey: "enabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "enabled") }
    }

    /// Gamma / overlay ceiling. 1.0 = no boost, 2.0 ≈ 2× headroom.
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

    static var freeHalfSide: FreeHalfSide {
        get {
            FreeHalfSide(rawValue: defaults.string(forKey: "freeHalfSide") ?? "") ?? .left
        }
        set { defaults.set(newValue.rawValue, forKey: "freeHalfSide") }
    }

    static var licenseKey: String {
        get { defaults.string(forKey: "licenseKey") ?? "" }
        set { defaults.set(newValue, forKey: "licenseKey") }
    }

    /// MVP local unlock: key must start with DAYLIT- and be at least 16 chars.
    /// Replace with signed tokens / Stripe before public sale.
    static var isLicensed: Bool {
        let key = licenseKey.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return key.hasPrefix("DAYLIT-") && key.count >= 16
    }
}
