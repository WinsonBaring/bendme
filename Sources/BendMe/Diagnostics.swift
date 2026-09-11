import AppKit
import Metal
import BendCore

enum Diagnostics {
    @MainActor static func captureTest() async throws {
        guard CGPreflightScreenCaptureAccess() else {
            throw BendError.unavailable("Screen Recording permission is required; this command does not request it.")
        }
        guard let screen = NSScreen.screens.first(where: { CGDisplayIsBuiltin($0.displayID) != 0 }) else {
            throw BendError.unavailable("No built-in display is available.")
        }
        let panel = NSPanel(contentRect: screen.frame, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.alphaValue = 0
        panel.ignoresMouseEvents = true
        panel.isReleasedWhenClosed = false
        panel.orderFrontRegardless()
        defer { panel.orderOut(nil); panel.close() }
        let capture = DesktopCapture()
        var frames = 0
        var dimensions = ""
        var failure: String?
        capture.onFrame = { frame in
            frames += 1
            dimensions = "\(CVPixelBufferGetWidth(frame))×\(CVPixelBufferGetHeight(frame))"
        }
        capture.onFailure = { failure = $0 }
        try await capture.start(displayID: screen.displayID, excluding: [CGWindowID(panel.windowNumber)], frameRate: 30)
        for _ in 0..<50 {
            if frames > 0 || failure != nil { break }
            try await Task.sleep(for: .milliseconds(100))
        }
        await capture.stop()
        if let failure { throw BendError.unavailable(failure) }
        guard frames > 0 else { throw BendError.unavailable("No complete screen frames arrived within five seconds.") }
        print("PASS: \(frames) complete live frames at \(dimensions); overlay exclusion resolved; capture stopped. No desktop frames saved.")
    }

    static func printHardware() {
        let sensor = LidSensor()
        sensor.start()
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        let report: [String: Any] = [
            "sensor": sensor.status,
            "angle": sensor.angle as Any? ?? NSNull(),
            "metal": MTLCreateSystemDefaultDevice()?.name ?? "Unavailable",
            "screenRecordingGranted": CGPreflightScreenCaptureAccess(),
            "builtInDisplay": NSScreen.screens.contains { CGDisplayIsBuiltin($0.displayID) != 0 }
        ]
        if let data = try? JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]),
           let json = String(data: data, encoding: .utf8) { print(json) }
        sensor.stop()
    }

    static func renderTests(directory: String) throws {
        guard let device = MTLCreateSystemDefaultDevice(), let image = PreviewArtwork.image(width: 640, height: 416) else {
            throw BendError.unavailable("Metal or artwork is unavailable.")
        }
        let root = URL(fileURLWithPath: directory, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let renderer = try MetalRenderer(device: device)
        var checks = [String]()
        try write(image, to: root.appendingPathComponent("original.png"))
        for style in FoldStyle.allCases {
            var settings = FoldSettings(); settings.style = style
            for angle in [135.0, 90.0, 60.0, 25.0, 5.0] {
                let progress = FoldGeometry.progress(angle: angle, clearAngle: settings.clearAngle)
                let result = try renderer.renderImage(image, progress: progress, settings: settings)
                let pixels = rgba(result)
                guard pixels.count == 640 * 416 * 4 else { throw BendError.unavailable("Unexpected pixel dimensions.") }
                let lit = stride(from: 0, to: pixels.count, by: 4).filter { pixels[$0] > 5 || pixels[$0 + 1] > 5 || pixels[$0 + 2] > 5 }.count
                guard lit > 1000 else { throw BendError.unavailable("\(style.title) at \(angle)° rendered an empty image.") }
                if angle == 135 {
                    let original = rgba(image)
                    let error = zip(original, pixels).reduce(0.0) { $0 + abs(Double($1.0) - Double($1.1)) } / Double(pixels.count)
                    guard error < 2 else { throw BendError.unavailable("Open-lid identity failed: mean byte error \(error).") }
                    checks.append("\(style.title): open-lid identity error \(String(format: "%.3f", error))")
                }
                if angle == 25 {
                    guard pixels[0] < 5, lit < 640 * 416 / 2 else { throw BendError.unavailable("Perspective failed to narrow the desktop.") }
                    checks.append("\(style.title): folded geometry contains \(lit) lit pixels")
                }
                try write(result, to: root.appendingPathComponent("\(style.rawValue)-\(Int(angle)).png"))
            }
        }
        let report: [String: Any] = ["result": "PASS", "device": device.name, "renders": 15, "checks": checks]
        let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: root.appendingPathComponent("gpu-report.json"), options: .atomic)
        print(String(decoding: data, as: UTF8.self))
    }

    static func write(_ image: CGImage, to url: URL) throws {
        let bitmap = NSBitmapImageRep(cgImage: image)
        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            throw BendError.unavailable("PNG encoding failed.")
        }
        try data.write(to: url, options: .atomic)
    }

    private static func rgba(_ image: CGImage) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
        bytes.withUnsafeMutableBytes { memory in
            guard let ctx = CGContext(data: memory.baseAddress, width: image.width, height: image.height,
                bitsPerComponent: 8, bytesPerRow: image.width * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
            ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        }
        return bytes
    }
}
