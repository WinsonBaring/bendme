import Foundation

public enum SetupStep: Int, CaseIterable, Sendable {
    case install, permission, tryEffect, ready

    public var title: String {
        switch self {
        case .install: return "Install"
        case .permission: return "Allow access"
        case .tryEffect: return "Try it"
        case .ready: return "Ready"
        }
    }
}

public struct SetupProgress: Equatable, Sendable {
    public var installed: Bool
    public var permissionGranted: Bool
    public var sensorAvailable: Bool
    public var sawEffect: Bool

    public init(installed: Bool, permissionGranted: Bool, sensorAvailable: Bool, sawEffect: Bool) {
        self.installed = installed
        self.permissionGranted = permissionGranted
        self.sensorAvailable = sensorAvailable
        self.sawEffect = sawEffect
    }

    public var step: SetupStep {
        if !installed { return .install }
        if !permissionGranted { return .permission }
        if sensorAvailable && sawEffect { return .ready }
        return .tryEffect
    }

    public static func isInstalled(appURL: URL, homeURL: URL) -> Bool {
        let path = appURL.standardizedFileURL.path
        let locations = ["/Applications", homeURL.appendingPathComponent("Applications").standardizedFileURL.path]
        return locations.contains { path.hasPrefix($0 + "/") }
    }

    public static func installedCopy(in folders: [URL], identifier: String, buildVersion: String) -> URL? {
        let candidates = folders.flatMap { folder in
            ((try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil,
                                                          options: [.skipsHiddenFiles])) ?? [])
                .filter { $0.pathExtension.lowercased() == "app" }
                .sorted { $0.lastPathComponent == "BendMe.app" && $1.lastPathComponent != "BendMe.app" }
        }
        return candidates.first { url in
            guard let data = try? Data(contentsOf: url.appendingPathComponent("Contents/Info.plist")),
                  let info = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else { return false }
            return info["CFBundleIdentifier"] as? String == identifier && info["CFBundleVersion"] as? String == buildVersion
        }
    }
}
