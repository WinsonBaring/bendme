import AppKit
import Combine
import MetalKit
import BendCore
import Carbon.HIToolbox

@MainActor
final class AppModel: ObservableObject {
    @Published var settings: FoldSettings {
        didSet {
            if let data = try? JSONEncoder().encode(settings.validated()) { defaults.set(data, forKey: "appearance") }
        }
    }
    @Published var angle: Double?
    @Published var sensorStatus = "Checking lid sensor…"
    @Published var enabled = false
    @Published var starting = false
    @Published var message: String?
    @Published var previewAngle: Double = 65
    @Published var followLid = false
    @Published var bends = 0
    @Published var permissionGranted = CGPreflightScreenCaptureAccess()
    @Published var overlayVisible = false
    let sensor = LidSensor()
    private let defaults: UserDefaults
    private var capture: DesktopCapture?
    private var panel: NSPanel?
    private var metalView: MTKView?
    private var renderer: MetalRenderer?
    private var ticker: Timer?
    private var watchdog: Timer?
    private var generation = 0
    private var firstFrame = false
    private var lastFrameTime = 0.0
    private var lastTick = 0.0
    private var smoothedProgress = 0.0
    private var counter = BendCounter()
    private var observers: [NSObjectProtocol] = []
    private var escapeMonitor: Any?
    private var hotkey: EventHotKeyRef?
    private var hotkeyHandler: EventHandlerRef?
    private var resumeAfterWake = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: "appearance"), let value = try? JSONDecoder().decode(FoldSettings.self, from: data) {
            settings = value.validated()
        } else { settings = FoldSettings() }
        sensor.onChange = { [weak self] value in
            guard let self else { return }
            self.angle = value
            self.sensorStatus = self.sensor.status
            if value == nil, self.enabled { self.fail("Lid sensor disconnected. The desktop effect has been paused.") }
        }
        refreshSensor()
        observeLifecycle()
        installEmergencyShortcut()
    }

    var effectivePreviewAngle: Double { followLid ? angle ?? 135 : previewAngle }
    var previewProgress: Double { FoldGeometry.progress(angle: effectivePreviewAngle, clearAngle: settings.clearAngle) }

    func refreshSensor() {
        sensor.start()
        angle = sensor.angle
        sensorStatus = sensor.status
    }

    func requestPermission() {
        permissionGranted = CGRequestScreenCaptureAccess()
        if !permissionGranted {
            message = "Allow BendMe in System Settings → Privacy & Security → Screen & System Audio Recording. Then reopen BendMe if macOS asks."
        }
    }

    func openPrivacySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    func toggle() { enabled || starting ? pause() : enable() }

    func enable() {
        guard !enabled, !starting else { return }
        permissionGranted = CGPreflightScreenCaptureAccess()
        guard permissionGranted else { requestPermission(); return }
        if sensor.angle == nil { refreshSensor() }
        guard sensor.angle != nil else { message = sensor.status; return }
        guard let screen = NSScreen.screens.first(where: { CGDisplayIsBuiltin($0.displayID) != 0 }) else {
            message = "Open the built-in MacBook display to enable the effect. External displays are not changed."
            return
        }
        guard let device = MTLCreateSystemDefaultDevice() else { message = "Metal is unavailable on this Mac."; return }
        generation += 1
        let session = generation
        starting = true
        message = nil
        do {
            let renderer = try MetalRenderer(device: device)
            let panel = NSPanel(contentRect: screen.frame, styleMask: [.borderless, .nonactivatingPanel],
                                backing: .buffered, defer: false, screen: screen)
            panel.isOpaque = true
            panel.backgroundColor = .black
            panel.hasShadow = false
            panel.ignoresMouseEvents = true
            panel.hidesOnDeactivate = false
            panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) - 1)
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
            panel.isReleasedWhenClosed = false
            let view = MTKView(frame: NSRect(origin: .zero, size: screen.frame.size), device: device)
            view.colorPixelFormat = .bgra8Unorm
            view.framebufferOnly = true
            view.isPaused = true
            view.enableSetNeedsDisplay = false
            view.delegate = renderer
            panel.contentView = view
            // Keep a registered, invisible window so ScreenCaptureKit can exclude it.
            panel.alphaValue = 0
            panel.orderFrontRegardless()
            self.panel = panel
            self.metalView = view
            self.renderer = renderer
            renderer.onFailure = { [weak self] error in self?.fail(error) }
            let capture = DesktopCapture()
            self.capture = capture
            capture.onFailure = { [weak self] error in
                guard self?.generation == session else { return }
                self?.fail("Screen capture stopped: \(error)")
            }
            capture.onFrame = { [weak self] frame in
                guard let self, self.generation == session else { return }
                self.firstFrame = true
                self.lastFrameTime = CACurrentMediaTime()
                self.renderer?.setFrame(frame)
            }
            Task {
                do {
                    try await capture.start(displayID: screen.displayID,
                                            excluding: [CGWindowID(panel.windowNumber)], frameRate: settings.frameRate)
                    guard generation == session else { await capture.stop(); return }
                    starting = false
                    enabled = true
                    lastTick = CACurrentMediaTime()
                    lastFrameTime = lastTick
                    ticker = Timer(timeInterval: 1 / 60, repeats: true) { [weak self] _ in
                        MainActor.assumeIsolated { self?.tick() }
                    }
                    if let ticker { RunLoop.main.add(ticker, forMode: .common) }
                    watchdog = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
                        MainActor.assumeIsolated {
                            guard let self, self.enabled else { return }
                            // An idle desktop need not emit frames. A missing first frame must never hide the desktop.
                            if !self.firstFrame, CACurrentMediaTime() - self.lastFrameTime > 5 {
                                self.fail("Screen capture produced no frames. Check Screen Recording permission and try again.")
                            }
                        }
                    }
                    if let watchdog { RunLoop.main.add(watchdog, forMode: .common) }
                } catch {
                    if generation == session { fail(error.localizedDescription) }
                }
            }
        } catch { fail(error.localizedDescription) }
    }

    private func tick() {
        guard enabled, let angle else { return }
        let now = CACurrentMediaTime()
        let target = FoldGeometry.progress(angle: angle, clearAngle: settings.clearAngle)
        smoothedProgress = FoldGeometry.smooth(current: smoothedProgress, target: target, delta: now - lastTick)
        lastTick = now
        renderer?.parameters = ShaderParameters(progress: smoothedProgress, settings: settings)
        if counter.observe(progress: target) { bends = counter.count }
        let show = firstFrame && smoothedProgress > 0.002
        if show {
            // Draw before revealing; keep this pass behind menu bar and cursor.
            metalView?.draw()
            if !overlayVisible {
                renderer?.onPresented = { [weak self] in
                    guard let self, self.enabled, self.smoothedProgress > 0.002 else { return }
                    self.panel?.alphaValue = 1
                    self.overlayVisible = true
                    self.renderer?.onPresented = nil
                }
            }
        } else if overlayVisible {
            panel?.alphaValue = 0
            overlayVisible = false
            if settings.sound { NSSound(named: "Pop")?.play() }
        }
    }

    func pause() {
        generation += 1
        enabled = false
        starting = false
        ticker?.invalidate(); ticker = nil
        watchdog?.invalidate(); watchdog = nil
        panel?.orderOut(nil)
        panel?.close(); panel = nil
        metalView?.delegate = nil; metalView = nil
        renderer?.clearFrame(); renderer = nil
        overlayVisible = false
        firstFrame = false
        smoothedProgress = 0
        let previous = capture
        capture = nil
        Task { await previous?.stop() }
    }

    func fail(_ reason: String) { pause(); message = reason }

    private func observeLifecycle() {
        let workspace = NSWorkspace.shared.notificationCenter
        observers.append(workspace.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.resumeAfterWake = self.enabled
                self.pause(); self.sensor.stop()
            }
        })
        observers.append(workspace.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                self.refreshSensor()
                if self.resumeAfterWake { self.resumeAfterWake = false; self.enable() }
            }
        })
        observers.append(workspace.addObserver(forName: NSWorkspace.sessionDidResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.pause() }
        })
        observers.append(NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.enabled || self.starting else { return }
                self.pause()
                self.message = "Display configuration changed. Enable BendMe again when your displays are ready."
            }
        })
        observers.append(NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.permissionGranted = CGPreflightScreenCaptureAccess() }
        })
        escapeMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { MainActor.assumeIsolated { self?.pause() } }
            return event
        }
    }

    private func installEmergencyShortcut() {
        // Carbon hotkeys work globally without Accessibility/Input Monitoring permission.
        var type = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let context = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
            guard let context else { return OSStatus(eventNotHandledErr) }
            MainActor.assumeIsolated {
                Unmanaged<AppModel>.fromOpaque(context).takeUnretainedValue().pause()
            }
            return noErr
        }, 1, &type, context, &hotkeyHandler)
        let result = RegisterEventHotKey(UInt32(kVK_ANSI_B), UInt32(cmdKey | optionKey | controlKey),
            EventHotKeyID(signature: 0x42454E44, id: 1), GetApplicationEventTarget(), 0, &hotkey)
        if result != noErr { message = "The global pause shortcut is unavailable. Use the menu-bar Pause command." }
    }

    func shutdown() {
        pause()
        sensor.stop()
        if let escapeMonitor { NSEvent.removeMonitor(escapeMonitor) }
        if let hotkey { UnregisterEventHotKey(hotkey) }
        if let hotkeyHandler { RemoveEventHandler(hotkeyHandler) }
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        observers.removeAll()
    }
}

extension NSScreen {
    var displayID: CGDirectDisplayID {
        (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0
    }
}
