// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PerplexityKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "PerplexityKit", targets: ["PerplexityKit"]),
    ],
    targets: [
        .target(name: "PerplexityKit"),
        .testTarget(name: "PerplexityKitTests", dependencies: ["PerplexityKit"]),
    ]
)
