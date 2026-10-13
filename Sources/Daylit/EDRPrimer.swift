import AppKit
import Metal
import QuartzCore

/// Tiny off-corner window that keeps compositor EDR mode alive with one Metal present.
/// Idle cost: essentially zero after the first frame; optional rare keepalive.
final class EDRPrimer {
    private var windows: [CGDirectDisplayID: NSWindow] = [:]
    private var layers: [CGDirectDisplayID: CAMetalLayer] = [:]
    private var device: MTLDevice?
    private var keepalive: Timer?

    func enable(for screens: [NSScreen]) {
        device = device ?? MTLCreateSystemDefaultDevice()
        guard let device else { return }

        var keep = Set<CGDirectDisplayID>()
        for screen in screens {
            guard let displayID = DisplaySupport.displayID(for: screen) else { continue }
            keep.insert(displayID)
            if windows[displayID] != nil {
                present(displayID: displayID)
                continue
            }

            let window = NSWindow(
                contentRect: NSRect(x: screen.frame.minX, y: screen.frame.maxY - 2, width: 2, height: 2),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .screenSaver
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            window.hasShadow = false

            let layer = CAMetalLayer()
            layer.device = device
            layer.pixelFormat = .rgba16Float
            layer.framebufferOnly = true
            layer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            layer.drawableSize = CGSize(width: 1, height: 1)
            layer.wantsExtendedDynamicRangeContent = true
            layer.isOpaque = false
            // High clear value holds EDR headroom without covering content.
            layer.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)

            let view = NSView(frame: NSRect(x: 0, y: 0, width: 2, height: 2))
            view.wantsLayer = true
            view.layer = layer
            window.contentView = view
            window.orderFrontRegardless()

            windows[displayID] = window
            layers[displayID] = layer
            present(displayID: displayID)
        }

        for id in windows.keys where !keep.contains(id) {
            tearDown(displayID: id)
        }

        // Rare keepalive only — avoids continuous GPU work.
        if keepalive == nil {
            keepalive = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
                self?.refreshAll()
            }
            if let keepalive {
                RunLoop.main.add(keepalive, forMode: .common)
            }
        }
    }

    func disable() {
        keepalive?.invalidate()
        keepalive = nil
        for id in Array(windows.keys) {
            tearDown(displayID: id)
        }
    }

    func refreshAll() {
        for id in windows.keys {
            present(displayID: id)
        }
    }

    private func tearDown(displayID: CGDirectDisplayID) {
        windows[displayID]?.orderOut(nil)
        windows[displayID] = nil
        layers[displayID] = nil
    }

    private func present(displayID: CGDirectDisplayID) {
        guard let layer = layers[displayID],
              let drawable = layer.nextDrawable(),
              let device = layer.device,
              let queue = device.makeCommandQueue(),
              let buffer = queue.makeCommandBuffer(),
              let pass = MTLRenderPassDescriptor() as MTLRenderPassDescriptor?
        else { return }

        pass.colorAttachments[0].texture = drawable.texture
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        pass.colorAttachments[0].clearColor = MTLClearColor(red: 8, green: 8, blue: 8, alpha: 1)

        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: pass) else { return }
        encoder.endEncoding()
        buffer.present(drawable)
        buffer.commit()
    }
}
