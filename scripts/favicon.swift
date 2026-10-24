// Resize the transparent logo master, preserving its alpha channel.
// Run from the repository root: swift scripts/favicon.swift
import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let sourceURL = root.appendingPathComponent("assets/logo-transparent.png")
guard let source = NSImage(contentsOf: sourceURL),
      let bitmap = NSBitmapImageRep(data: try Data(contentsOf: sourceURL)) else {
    fatalError("Cannot load assets/logo-transparent.png. Run from the repository root.")
}
source.size = NSSize(width: bitmap.pixelsWide, height: bitmap.pixelsHigh)
for side in [16, 32, 48, 180, 192, 512] {
    let output = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: side, pixelsHigh: side, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    output.bitmapData!.initialize(repeating: 0, count: output.bytesPerRow * side)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: output)
    NSGraphicsContext.current?.imageInterpolation = .high
    let size = CGFloat(side)
    source.draw(in: NSRect(x: 0, y: 0, width: size, height: size), from: NSRect(origin: .zero, size: source.size), operation: .copy, fraction: 1, respectFlipped: false, hints: [.interpolation: NSImageInterpolation.high])
    NSGraphicsContext.restoreGraphicsState()
    let name = side == 180 ? "apple-touch-icon.png" : "favicon-\(side).png"
    try output.representation(using: .png, properties: [:])!.write(to: root.appendingPathComponent("assets/\(name)"))
    precondition(output.colorAt(x: 0, y: 0)!.alphaComponent == 0, "Icon background must be transparent")
}
print("Created six transparent favicon / touch icon sizes.")
