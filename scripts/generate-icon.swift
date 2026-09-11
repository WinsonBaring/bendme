import AppKit

guard CommandLine.arguments.count == 2 else { fatalError("Expected output .icns path") }
let output = URL(fileURLWithPath: CommandLine.arguments[1])
let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("iconset")
try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: temporary) }

func draw(size: Int) throws -> Data {
    guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
        bytesPerRow: size * 4, bitsPerPixel: 32), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(domain: "BendMeIcon", code: 1)
    }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    defer { NSGraphicsContext.restoreGraphicsState() }
    context.cgContext.scaleBy(x: CGFloat(size) / 1024, y: CGFloat(size) / 1024)
    let body = NSBezierPath(roundedRect: NSRect(x: 44, y: 44, width: 936, height: 936), xRadius: 206, yRadius: 206)
    NSColor(red: 0.09, green: 0.11, blue: 0.15, alpha: 1).setFill(); body.fill()
    NSColor(white: 1, alpha: 0.13).setStroke(); body.lineWidth = 3; body.stroke()
    let screen = NSBezierPath()
    screen.move(to: NSPoint(x: 230, y: 278))
    screen.line(to: NSPoint(x: 300, y: 750))
    screen.curve(to: NSPoint(x: 721, y: 650), controlPoint1: NSPoint(x: 438, y: 690), controlPoint2: NSPoint(x: 586, y: 660))
    screen.line(to: NSPoint(x: 794, y: 278)); screen.close()
    let gradient = NSGradient(starting: NSColor(red: 0.97, green: 0.71, blue: 0.47, alpha: 1),
                              ending: NSColor(red: 0.78, green: 0.40, blue: 0.26, alpha: 1))
    gradient?.draw(in: screen, angle: -70)
    NSColor(red: 1, green: 0.84, blue: 0.65, alpha: 1).setStroke()
    screen.lineWidth = 10; screen.lineJoinStyle = .round; screen.stroke()
    let base = NSBezierPath(roundedRect: NSRect(x: 182, y: 228, width: 660, height: 26), xRadius: 13, yRadius: 13)
    NSColor(white: 0.74, alpha: 1).setFill(); base.fill()
    guard let data = bitmap.representation(using: .png, properties: [:]) else { throw NSError(domain: "BendMeIcon", code: 2) }
    return data
}
for size in [16, 32, 128, 256, 512] {
    try draw(size: size).write(to: temporary.appendingPathComponent("icon_\(size)x\(size).png"))
    try draw(size: size * 2).write(to: temporary.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
}
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", temporary.path, "-o", output.path]
try process.run(); process.waitUntilExit()
guard process.terminationStatus == 0 else { throw NSError(domain: "BendMeIcon", code: Int(process.terminationStatus)) }
