// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "BendMe",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "BendMe", targets: ["BendMe"])],
    targets: [
        .target(name: "BendCore", exclude: ["README.md"]),
        .executableTarget(name: "BendMe", dependencies: ["BendCore"],
                          exclude: ["README.md"], resources: [.copy("Resources")]),
        .testTarget(name: "BendCoreTests", dependencies: ["BendCore"], exclude: ["README.md"])
    ]
)
