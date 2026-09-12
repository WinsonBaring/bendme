// Synthetic layout fixtures only. No screen capture, permission prompts or hardware services are started.
import AppKit
import SwiftUI

@main
struct RenderSetup {
    @MainActor static func main() throws {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let output = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "dist/SetupVerification")
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        for name in ["install", "permission", "try-effect", "unsupported", "ready", "capture-error", "permission-settings", "permission-requesting", "try-starting", "try-enabled", "appearance"] {
            let suite = "local.bendme.layout." + UUID().uuidString
            let defaults = UserDefaults(suiteName: suite)!
            let model = AppModel(defaults: defaults, servicesEnabled: false)
            if name == "appearance" { model.showSetup = false }
            model.installedInApplications = name != "install"
            model.permissionGranted = !["install", "permission", "permission-settings", "permission-requesting"].contains(name)
            model.needsScreenSettings = name == "permission-settings"
            model.requestingScreenAccess = name == "permission-requesting"
            model.angle = name == "unsupported" ? nil : 113
            model.sensorStatus = name == "unsupported" ? "No compatible lid sensor found." : "Lid sensor connected"
            model.starting = name == "try-starting"
            model.enabled = name == "try-enabled"
            model.setupSawEffect = name == "ready"
            if name == "capture-error" { model.message = "Screen capture could not start. Review Screen Recording permission and try again." }
            let size = NSSize(width: 900, height: 780)
            let host: NSView = NSHostingView(rootView: SettingsView(model: model))
            let window = NSWindow(contentRect: NSRect(origin: NSPoint(x: -12000, y: -12000), size: size), styleMask: .borderless, backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            host.frame = NSRect(origin: .zero, size: size)
            window.contentView = host
            window.orderFront(nil)
            RunLoop.main.run(until: Date().addingTimeInterval(0.4))
            host.layoutSubtreeIfNeeded()
            guard let bitmap = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { fatalError("Cannot render \(name)") }
            host.cacheDisplay(in: host.bounds, to: bitmap)
            guard let data = bitmap.representation(using: .png, properties: [:]) else { fatalError("No image \(name)") }
            try data.write(to: output.appendingPathComponent(name + ".png"))
            window.close()
            model.shutdown()
            defaults.removePersistentDomain(forName: suite)
            print("Rendered fixture:", name)
        }
    }
}
