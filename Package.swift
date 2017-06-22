// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SwiftLogicSystem",
    targets: [
        .target(name: "SwiftLogicSystem"),
        .testTarget(
            name: "SwiftLogicSystemTests",
            dependencies: ["SwiftLogicSystem"]
        ),
    ]
)
