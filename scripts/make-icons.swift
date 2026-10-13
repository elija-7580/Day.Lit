import AppKit

let resources = URL(fileURLWithPath: CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : FileManager.default.currentDirectoryPath + "/Resources")

func pngData(from image: NSImage, pixelsWide: Int, pixelsHigh: Int) throws -> Data {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelsWide,
        pixelsHigh: pixelsHigh,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "DayLit", code: 1)
    }
    rep.size = NSSize(width: pixelsWide, height: pixelsHigh)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    image.draw(
        in: NSRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh),
        from: .zero,
        operation: .copy,
        fraction: 1.0
    )
    NSGraphicsContext.restoreGraphicsState()
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "DayLit", code: 2)
    }
    return data
}

func menuTemplate(pixels: Int) throws {
    let conf = NSImage.SymbolConfiguration(pointSize: CGFloat(pixels) * 0.82, weight: .semibold)
    let symbol = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: nil)!
        .withSymbolConfiguration(conf)!

    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { return }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    let tw = symbol.size.width
    let th = symbol.size.height
    let rect = NSRect(
        x: (CGFloat(pixels) - tw) / 2,
        y: (CGFloat(pixels) - th) / 2,
        width: tw,
        height: th
    )
    symbol.draw(in: rect)
    NSGraphicsContext.restoreGraphicsState()

    for y in 0..<rep.pixelsHigh {
        for x in 0..<rep.pixelsWide {
            guard let c = rep.colorAt(x: x, y: y) else { continue }
            rep.setColor(
                NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: c.alphaComponent),
                atX: x,
                y: y
            )
        }
    }
    let name = pixels == 18 ? "MenuBarIcon.png" : "MenuBarIcon@2x.png"
    try rep.representation(using: .png, properties: [:])?
        .write(to: resources.appendingPathComponent(name))
}

func appIconPNG() throws {
    let size = 1024
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { return }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high

    let radius = CGFloat(size) * 0.2237
    let squircle = NSBezierPath(
        roundedRect: NSRect(x: 0, y: 0, width: size, height: size),
        xRadius: radius,
        yRadius: radius
    )
    NSColor(calibratedRed: 0.125, green: 0.125, blue: 0.133, alpha: 1).setFill()
    squircle.fill()

    let conf = NSImage.SymbolConfiguration(pointSize: 470, weight: .medium)
    let symbol = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: nil)!
        .withSymbolConfiguration(conf)!
    symbol.isTemplate = true

    let tw = symbol.size.width
    let th = symbol.size.height
    let rect = NSRect(
        x: (CGFloat(size) - tw) / 2,
        y: (CGFloat(size) - th) / 2 - 6,
        width: tw,
        height: th
    )
    let gold = NSColor(calibratedRed: 1.0, green: 0.78, blue: 0.30, alpha: 1)
    gold.set()
    symbol.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
    rect.fill(using: .sourceAtop)

    NSGraphicsContext.restoreGraphicsState()
    try rep.representation(using: .png, properties: [:])?
        .write(to: resources.appendingPathComponent("daylit-icon-1024.png"))
}

try menuTemplate(pixels: 18)
try menuTemplate(pixels: 36)
try appIconPNG()
print("icons written to \(resources.path)")
