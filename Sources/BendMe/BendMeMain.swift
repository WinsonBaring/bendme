import AppKit
import SwiftUI
import Combine
#if canImport(BendCore)
import BendCore
#endif

@main
enum BendMeMain {
    @MainActor static func main() {
        let args = CommandLine.arguments
        if args.contains("--capture-test") {
            let app = NSApplication.shared
            app.setActivationPolicy(.accessory)
            Task { @MainActor in
                do { try await Diagnostics.captureTest(); exit(0) }
                catch { fputs("Capture test failed: \(error.localizedDescription)\n", stderr); exit(1) }
            }
            app.run()
            return
        }
        if args.contains("--diagnose") {
            Diagnostics.printHardware()
            return
        }
        if let index = args.firstIndex(of: "--self-test") {
            do {
                let path = args.count > index + 1 ? args[index + 1] : "dist/verification"
                try Diagnostics.renderTests(directory: path)
            } catch {
                fputs("Self-test failed: \(error.localizedDescription)\n", stderr)
                exit(1)
            }
            return
        }
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        withExtendedLifetime(delegate) { app.run() }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var model: AppModel?
    private var statusItem: NSStatusItem?
    private var window: NSWindow?
    private var subscription: AnyCancellable?
    private var toggleItem: NSMenuItem?
    private var sensorItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let model = AppModel()
        self.model = model
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(systemSymbolName: "macbook", accessibilityDescription: "BendMe")
        item.button?.toolTip = "BendMe — desktop lid effect"
        let menu = NSMenu()
        let title = NSMenuItem(title: "BendMe", action: nil, keyEquivalent: "")
        title.isEnabled = false
        menu.addItem(title)
        sensorItem = NSMenuItem(title: "Lid sensor", action: nil, keyEquivalent: "")
        if let sensorItem { menu.addItem(sensorItem) }
        menu.addItem(.separator())
        toggleItem = menu.addItem(withTitle: "Enable BendMe", action: #selector(toggle), keyEquivalent: "")
        toggleItem?.target = self
        let settings = menu.addItem(withTitle: "Settings…", action: #selector(showSettings), keyEquivalent: ",")
        settings.target = self
        let pause = menu.addItem(withTitle: "Pause effect", action: #selector(pause), keyEquivalent: "b")
        pause.keyEquivalentModifierMask = [.control, .option, .command]
        pause.target = self
        menu.addItem(.separator())
        let quitMenuItem = menu.addItem(withTitle: "Quit BendMe", action: #selector(quit), keyEquivalent: "q")
        quitMenuItem.target = self
        item.menu = menu
        statusItem = item
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: "BendMe")
        let openSettings = appMenu.addItem(withTitle: "BendMe Settings…", action: #selector(showSettings), keyEquivalent: ",")
        openSettings.target = self
        appMenu.addItem(.separator())
        let quitApp = appMenu.addItem(withTitle: "Quit BendMe", action: #selector(quit), keyEquivalent: "q")
        quitApp.target = self
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        let windowMenuItem = NSMenuItem()
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenuItem.submenu = windowMenu
        mainMenu.addItem(windowMenuItem)
        NSApp.mainMenu = mainMenu
        subscription = model.objectWillChange.sink { [weak self] in
            DispatchQueue.main.async { self?.refreshMenu() }
        }
        refreshMenu()
        showSettings()
    }

    private func refreshMenu() {
        guard let model else { return }
        toggleItem?.title = model.starting ? "Cancel starting" : model.enabled ? "Pause BendMe" : "Enable BendMe"
        sensorItem?.title = model.angle.map { "Lid \(Int($0))°  ·  \(model.enabled ? "Enabled" : "Paused")" } ?? "Manual preview available"
    }

    @objc func showSettings() {
        guard let model else { return }
        if window == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 900, height: 780),
                styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
            window.title = "BendMe"
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.toolbarStyle = .unified
            window.backgroundColor = NSColor(red: 0.08, green: 0.085, blue: 0.099, alpha: 1)
            window.contentView = NSHostingView(rootView: SettingsView(model: model))
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
    @objc private func toggle() { model?.toggle() }
    @objc private func pause() { model?.pause() }
    @objc private func quit() { NSApp.terminate(nil) }
    func applicationWillTerminate(_ notification: Notification) { model?.shutdown() }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings(); return true
    }
}
