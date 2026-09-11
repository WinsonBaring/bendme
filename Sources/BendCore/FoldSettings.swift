import Foundation

public enum FoldStyle: String, Codable, CaseIterable, Identifiable {
    case silk, shade, frost
    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
    public var subtitle: String {
        switch self {
        case .silk: return "Soft and fluid"
        case .shade: return "Deep and dimensional"
        case .frost: return "Light through glass"
        }
    }
}

public struct FoldSettings: Codable, Equatable {
    public var style: FoldStyle = .silk
    public var perspective: Double = 0.8
    public var blur: Double = 0.65
    public var shadow: Double = 0.4
    public var clearAngle: Double = 100
    public var sound: Bool = false
    public var frameRate: Int = 60
    public init() {}

    public func validated() -> Self {
        var result = self
        result.perspective = clamp(perspective, 0...1, fallback: 0.8)
        result.blur = clamp(blur, 0...1, fallback: 0.65)
        result.shadow = clamp(shadow, 0...1, fallback: 0.4)
        result.clearAngle = clamp(clearAngle, 60...135, fallback: 100)
        result.frameRate = frameRate == 30 ? 30 : 60
        return result
    }
}

public func clamp(_ value: Double, _ range: ClosedRange<Double>, fallback: Double) -> Double {
    value.isFinite ? min(range.upperBound, max(range.lowerBound, value)) : fallback
}

public enum FoldGeometry {
    public static func progress(angle: Double, clearAngle: Double) -> Double {
        guard angle.isFinite, clearAngle.isFinite else { return 0 }
        let threshold = clamp(clearAngle, 60...135, fallback: 100)
        let t = clamp((threshold - angle) / (threshold - 5), 0...1, fallback: 0)
        return t * t * (3 - 2 * t)
    }

    /// Only report 1 contains the 9-bit angular position, in integer degrees.
    public static func decodeReport(_ bytes: [UInt8]) -> Double? {
        guard bytes.count >= 3, bytes[0] == 1 else { return nil }
        let value = Int(bytes[1]) | (Int(bytes[2]) << 8)
        return (0...360).contains(value) ? Double(value) : nil
    }

    /// Exponential smoothing with the same response at 30 and 60 fps.
    public static func smooth(current: Double, target: Double, delta: Double) -> Double {
        let dt = clamp(delta, 0...0.1, fallback: 1 / 60)
        return current + (target - current) * (1 - exp(-dt * 18))
    }
}

public struct BendCounter {
    private var armed = true
    public private(set) var count = 0
    public init() {}
    @discardableResult public mutating func observe(progress: Double) -> Bool {
        if progress < 0.15 { armed = true }
        guard armed, progress > 0.6 else { return false }
        count += 1
        armed = false
        return true
    }
}
