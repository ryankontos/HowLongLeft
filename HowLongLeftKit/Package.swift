// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HowLongLeftKit",
    platforms: [
        .macOS(.v14), .iOS(.v17), .watchOS(.v10),
    ],
    products: [
        .library(
            name: "HowLongLeftKit",
            type: .dynamic,
            targets: ["HowLongLeftKit"]),
    ],
    dependencies: [
        // Adding the Defaults package from GitHub
        .package(url: "https://github.com/sindresorhus/Defaults.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "HowLongLeftKit", dependencies: ["Defaults"], swiftSettings: [
                
            ]),
        .testTarget(
            name: "How Long Left KitTests",
            dependencies: ["HowLongLeftKit", "Defaults"]),
    ]
)
