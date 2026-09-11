import XCTest
@testable import BendCore

final class FoldTests: XCTestCase {
    func testOpenLidAlwaysClears() {
        for threshold in stride(from: 60.0, through: 135, by: 5) {
            XCTAssertEqual(FoldGeometry.progress(angle: threshold, clearAngle: threshold), 0)
            XCTAssertEqual(FoldGeometry.progress(angle: threshold + 10, clearAngle: threshold), 0)
        }
    }
    func testClosingLidIsMonotonicAndBounded() {
        var previous = 0.0
        for angle in stride(from: 180.0, through: -20, by: -0.5) {
            let progress = FoldGeometry.progress(angle: angle, clearAngle: 100)
            XCTAssertGreaterThanOrEqual(progress, previous)
            XCTAssertTrue((0...1).contains(progress))
            previous = progress
        }
        XCTAssertEqual(previous, 1)
    }
    func testNonfiniteSensorDataFailsOpen() {
        XCTAssertEqual(FoldGeometry.progress(angle: .nan, clearAngle: 100), 0)
        XCTAssertEqual(FoldGeometry.progress(angle: .infinity, clearAngle: 100), 0)
        XCTAssertEqual(FoldGeometry.progress(angle: 30, clearAngle: .nan), 0)
    }
    func testHIDPacketValidation() {
        XCTAssertEqual(FoldGeometry.decodeReport([1, 90, 0]), 90)
        XCTAssertEqual(FoldGeometry.decodeReport([1, 104, 1]), 360)
        XCTAssertNil(FoldGeometry.decodeReport([1]))
        XCTAssertNil(FoldGeometry.decodeReport([2, 90, 0]))
        XCTAssertNil(FoldGeometry.decodeReport([1, 255, 255]))
        XCTAssertNil(FoldGeometry.decodeReport([1, 105, 1]))
    }
    func testCorruptSettingsAreSanitized() {
        var settings = FoldSettings()
        settings.perspective = .nan; settings.blur = -4; settings.shadow = 9
        settings.clearAngle = .infinity; settings.frameRate = 999
        let safe = settings.validated()
        XCTAssertEqual(safe.perspective, 0.8)
        XCTAssertEqual(safe.blur, 0)
        XCTAssertEqual(safe.shadow, 1)
        XCTAssertEqual(safe.clearAngle, 100)
        XCTAssertEqual(safe.frameRate, 60)
    }
    func testSettingsRoundTrip() throws {
        var settings = FoldSettings(); settings.style = .frost; settings.frameRate = 30
        let data = try JSONEncoder().encode(settings)
        XCTAssertEqual(try JSONDecoder().decode(FoldSettings.self, from: data), settings)
    }
    func testSmoothingIndependentOfFrameRate() {
        var thirty = 0.0, sixty = 0.0
        for _ in 0..<30 { thirty = FoldGeometry.smooth(current: thirty, target: 1, delta: 1 / 30) }
        for _ in 0..<60 { sixty = FoldGeometry.smooth(current: sixty, target: 1, delta: 1 / 60) }
        XCTAssertEqual(thirty, sixty, accuracy: 0.000001)
    }
    func testCounterDoesNotCountJitter() {
        var counter = BendCounter()
        for value in [0.0, 0.4, 0.61, 0.59, 0.62, 0.3, 0.7] { counter.observe(progress: value) }
        XCTAssertEqual(counter.count, 1)
        counter.observe(progress: 0.1); counter.observe(progress: 0.8)
        XCTAssertEqual(counter.count, 2)
    }
}
