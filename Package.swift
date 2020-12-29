// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-package-info",
    platforms: [
        .macOS(.v10_10)
    ],
    products: [
        .executable(
            name: "SwiftPackageInfo",
            targets: [
                "Run"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "Run",
            dependencies: [
                .target(name: "Core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "RunTests",
            dependencies: [
                .target(name: "Run")
            ]
        ),
        .target(
            name: "Core",
            dependencies: []
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                .target(name: "Core")
            ]
        )
    ]
)
