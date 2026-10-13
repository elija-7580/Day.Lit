import CoreGraphics

/// Writes a linear transfer table with ceiling > 1.0 so SDR pixels map into EDR headroom.
enum GammaBoost {
    private static let sampleCount = 256

    static func apply(displayID: CGDirectDisplayID, ceiling: Float) {
        var red = [Float](repeating: 0, count: sampleCount)
        var green = [Float](repeating: 0, count: sampleCount)
        var blue = [Float](repeating: 0, count: sampleCount)
        let c = max(ceiling, 1.0)
        for i in 0..<sampleCount {
            let t = Float(i) / Float(sampleCount - 1)
            let v = t * c
            red[i] = v
            green[i] = v
            blue[i] = v
        }
        red.withUnsafeMutableBufferPointer { r in
            green.withUnsafeMutableBufferPointer { g in
                blue.withUnsafeMutableBufferPointer { b in
                    _ = CGSetDisplayTransferByTable(
                        displayID,
                        UInt32(sampleCount),
                        r.baseAddress,
                        g.baseAddress,
                        b.baseAddress
                    )
                }
            }
        }
    }

    static func restore() {
        CGDisplayRestoreColorSyncSettings()
    }
}
