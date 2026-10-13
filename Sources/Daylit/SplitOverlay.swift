import AppKit
import Metal
import QuartzCore

/// Free-tier half-screen boost: click-through multiply overlay on the left half only.
/// Uses a low-rate timer (~2 Hz) so cost stays small versus continuous 60 fps.
final class SplitOverlay {
    private var window: NSWindow?
    private var layer: CAMetalLayer?
    private var timer: Timer?
    private var factor: Float = 1.6

    func show(on screen: NSScreen, factor: Float, side: FreeHalfSide = .left) {
        self.factor = max(factor, 1.0)
        let width = screen.frame.width / 2
        let half = NSRect(
            x: side == .left ? screen.frame.minX : screen.frame.minX + width,
            y: screen.frame.minY,
            width: width,
            height: screen.frame.height
        )

        if window == nil {
            guard let device = MTLCreateSystemDefaultDevice() else { return }
            let win = NSWindow(
                contentRect: half,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            win.isOpaque = false
            win.backgroundColor = .clear
            win.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
            win.ignoresMouseEvents = true
            win.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
            win.hasShadow = false
            win.alphaValue = 1

            let metal = CAMetalLayer()
            metal.device = device
            metal.pixelFormat = .rgba16Float
            metal.framebufferOnly = true
            metal.wantsExtendedDynamicRangeContent = true
            metal.isOpaque = false
            metal.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
            metal.compositingFilter = "multiplyBlendMode"
            metal.frame = CGRect(origin: .zero, size: half.size)
            metal.drawableSize = CGSize(width: max(half.width, 1), height: max(half.height, 1))

            let view = NSView(frame: NSRect(origin: .zero, size: half.size))
            view.wantsLayer = true
            view.layer = metal
            win.contentView = view

            window = win
            layer = metal
        } else {
            window?.setFrame(half, display: true)
            layer?.frame = CGRect(origin: .zero, size: half.size)
            layer?.drawableSize = CGSize(width: max(half.width, 1), height: max(half.height, 1))
        }

        window?.orderFrontRegardless()
        render()

        if timer == nil {
            let t = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.render()
            }
            RunLoop.main.add(t, forMode: .common)
            timer = t
        }
    }

    func hide() {
        timer?.invalidate()
        timer = nil
        window?.orderOut(nil)
        window = nil
        layer = nil
    }

    private func render() {
        guard let layer,
              let drawable = layer.nextDrawable(),
              let device = layer.device,
              let queue = device.makeCommandQueue(),
              let buffer = queue.makeCommandBuffer()
        else { return }

        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = drawable.texture
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        // Multiply with EDR > 1 brightens content under the overlay.
        let v = Double(factor)
        pass.colorAttachments[0].clearColor = MTLClearColor(red: v, green: v, blue: v, alpha: 1)

        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: pass) else { return }
        encoder.endEncoding()
        buffer.present(drawable)
        buffer.commit()
    }
}
