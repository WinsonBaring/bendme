import Foundation
import IOKit.hid

/// All methods and callbacks run on the main run loop.
public final class LidSensor {
    public private(set) var angle: Double?
    public private(set) var status = "Checking lid sensor…"
    public var onChange: ((Double?) -> Void)?
    private var device: IOHIDDevice?
    private var watchdog: Timer?
    private var failures = 0

    public init() {}

    public func start() {
        stop()
        let matching = ["DeviceUsagePage": 0x20, "DeviceUsage": 0x8A] as CFDictionary
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, 0)
        IOHIDManagerSetDeviceMatching(manager, matching)
        guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice>,
              let found = devices.first else {
            status = "No compatible lid sensor. Manual preview is available."
            onChange?(nil)
            return
        }
        let result = IOHIDDeviceOpen(found, 0)
        guard result == kIOReturnSuccess else {
            status = "Lid sensor could not open (\(result)). Try again after waking your Mac."
            onChange?(nil)
            return
        }
        device = found
        status = "Waiting for lid sensor"
        IOHIDDeviceRegisterInputValueCallback(found, { context, result, _, value in
            guard result == kIOReturnSuccess, let context else { return }
            let sensor = Unmanaged<LidSensor>.fromOpaque(context).takeUnretainedValue()
            let element = IOHIDValueGetElement(value)
            guard IOHIDElementGetUsagePage(element) == 0x20,
                  IOHIDElementGetUsage(element) == 0x047F else { return }
            sensor.accept(Double(IOHIDValueGetIntegerValue(value)))
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDDeviceScheduleWithRunLoop(found, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        // Some Apple firmwares expose reads but never deliver input notifications.
        // Bounded 30 Hz reads support those machines and detect device loss.
        poll()
        watchdog = Timer(timeInterval: 1 / 30, repeats: true) { [weak self] _ in self?.poll() }
        if let watchdog { RunLoop.main.add(watchdog, forMode: .common) }
    }

    private func poll() {
        guard let device else { return }
        var report = [UInt8](repeating: 0, count: 8)
        var length = report.count
        let result = IOHIDDeviceGetReport(device, kIOHIDReportTypeFeature, 1, &report, &length)
        guard result == kIOReturnSuccess,
              let reading = FoldGeometry.decodeReport(Array(report.prefix(length))) else {
            failures += 1
            if failures == 30 {
                angle = nil
                status = "Sensor stopped responding. Pause and retry."
                onChange?(nil)
            }
            return
        }
        accept(reading)
    }

    private func accept(_ value: Double) {
        guard value.isFinite, (0...360).contains(value) else { return }
        failures = 0
        status = "Lid sensor connected"
        if angle != value { angle = value; onChange?(value) }
    }

    public func stop() {
        watchdog?.invalidate()
        watchdog = nil
        if let device {
            IOHIDDeviceUnscheduleFromRunLoop(device, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
            IOHIDDeviceRegisterInputValueCallback(device, nil, nil)
            IOHIDDeviceClose(device, 0)
        }
        device = nil
        angle = nil
    }

    deinit { stop() }
}
