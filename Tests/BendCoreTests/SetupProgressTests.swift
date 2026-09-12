import XCTest
@testable import BendCore

final class SetupProgressTests: XCTestCase {
    func testFreshDownloadStartsWithInstallationEvenIfPermissionAlreadyExists() {
        let status = SetupProgress(installed: false, permissionGranted: true, sensorAvailable: true, sawEffect: true)
        XCTAssertEqual(status.step, .install)
    }

    func testInstallationDoesNotImplyPermission() {
        let status = SetupProgress(installed: true, permissionGranted: false, sensorAvailable: true, sawEffect: false)
        XCTAssertEqual(status.step, .permission)
    }

    func testPermissionAloneDoesNotCompleteSetup() {
        let status = SetupProgress(installed: true, permissionGranted: true, sensorAvailable: true, sawEffect: false)
        XCTAssertEqual(status.step, .tryEffect)
    }

    func testMissingSensorCannotCompleteLiveSetup() {
        let status = SetupProgress(installed: true, permissionGranted: true, sensorAvailable: false, sawEffect: true)
        XCTAssertEqual(status.step, .tryEffect)
    }

    func testPresentedEffectCompletesLiveSetup() {
        let status = SetupProgress(installed: true, permissionGranted: true, sensorAvailable: true, sawEffect: true)
        XCTAssertEqual(status.step, .ready)
    }

    func testRevokedPermissionReturnsToPermissionStep() {
        var status = SetupProgress(installed: true, permissionGranted: true, sensorAvailable: true, sawEffect: true)
        status.permissionGranted = false
        XCTAssertEqual(status.step, .permission)
    }

    func testInstalledLocationRequiresAnApplicationsDirectoryBoundary() {
        let home = URL(fileURLWithPath: "/Users/test")
        for path in ["/Applications/BendMe.app", "/Applications/Utilities/BendMe.app", "/Users/test/Applications/BendMe.app"] {
            XCTAssertTrue(SetupProgress.isInstalled(appURL: URL(fileURLWithPath: path), homeURL: home), path)
        }
        for path in ["/Applications-copy/BendMe.app", "/Users/test/Downloads/BendMe.app", "/Volumes/BendMe/BendMe.app", "/private/tmp/AppTranslocation/example/d/BendMe.app"] {
            XCTAssertFalse(SetupProgress.isInstalled(appURL: URL(fileURLWithPath: path), homeURL: home), path)
        }
    }

    func testRenamedCopiesAreFoundAndOlderVersionsAreRejected() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let old = try makeApp(in: root, name: "BendMe.app", identifier: "test.bendme", version: "2")
        let current = try makeApp(in: root, name: "BendMe-2.app", identifier: "test.bendme", version: "3")
        _ = try makeApp(in: root, name: "Other.app", identifier: "test.other", version: "3")
        XCTAssertEqual(SetupProgress.installedCopy(in: [root], identifier: "test.bendme", buildVersion: "3")?.resolvingSymlinksInPath().path, current.resolvingSymlinksInPath().path)
        // Replacing the old app must be detected without cached Bundle metadata.
        _ = try makeApp(in: root, name: "BendMe.app", identifier: "test.bendme", version: "3")
        XCTAssertEqual(SetupProgress.installedCopy(in: [root], identifier: "test.bendme", buildVersion: "3")?.resolvingSymlinksInPath().path, old.resolvingSymlinksInPath().path)
    }

    func testIncompleteAndUnrelatedCopiesDoNotEnableOpenInstalled() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root.appendingPathComponent("BendMe.app/Contents"), withIntermediateDirectories: true)
        _ = try makeApp(in: root, name: "Other.app", identifier: "test.other", version: "3")
        XCTAssertNil(SetupProgress.installedCopy(in: [root, root.appendingPathComponent("missing")], identifier: "test.bendme", buildVersion: "3"))
    }

    private func makeApp(in root: URL, name: String, identifier: String, version: String) throws -> URL {
        let app = root.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: app.appendingPathComponent("Contents"), withIntermediateDirectories: true)
        let data = try PropertyListSerialization.data(fromPropertyList: ["CFBundleIdentifier": identifier, "CFBundleVersion": version], format: .xml, options: 0)
        try data.write(to: app.appendingPathComponent("Contents/Info.plist"), options: .atomic)
        return app
    }
}
