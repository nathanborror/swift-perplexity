// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-perplexity",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "Perplexity", targets: ["Perplexity"]),
    ],
    targets: [
        .target(name: "Perplexity"),
        .testTarget(name: "PerplexityTests", dependencies: ["Perplexity"]),
    ]
)
