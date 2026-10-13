import AppKit
import CoreGraphics

enum DisplaySupport {
    static var builtInEDRScreens: [NSScreen] {
        NSScreen.screens.filter { screen in
            guard screen.maximumPotentialExtendedDynamicRangeColorComponentValue > 1.001 else {
                return false
            }
            // Prefer built-in panel; still allow Pro Display XDR-style externals with headroom.
            return true
        }
    }

    static var hasSupportedDisplay: Bool {
        !builtInEDRScreens.isEmpty
    }

    static func displayID(for screen: NSScreen) -> CGDirectDisplayID? {
        guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return nil
        }
        return CGDirectDisplayID(number.uint32Value)
    }
}
