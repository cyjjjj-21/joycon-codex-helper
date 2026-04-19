// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "JoyConCodexHelper",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "JoyConCodexCore", targets: ["JoyConCodexCore"]),
        .executable(name: "JoyConCodexHelper", targets: ["JoyConCodexHelper"])
    ],
    targets: [
        .target(name: "JoyConCodexCore"),
        .executableTarget(
            name: "JoyConCodexHelper",
            dependencies: ["JoyConCodexCore"]
        ),
        .testTarget(
            name: "JoyConCodexCoreTests",
            dependencies: ["JoyConCodexCore"]
        ),
        .testTarget(
            name: "JoyConCodexHelperTests",
            dependencies: ["JoyConCodexHelper", "JoyConCodexCore"]
        )
    ]
)
