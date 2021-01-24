// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-package-info",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "swift-package-info",
            targets: [
                "Run"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            .upToNextMinor(from: "0.3.0")
        ),
        .package(
            url: "https://github.com/tuist/XcodeProj.git",
            .upToNextMinor(from: "7.18.0")
        ),
        .package(
            url: "https://github.com/apple/swift-tools-support-core.git",
            .upToNextMinor(from: "0.1.11")
        ),
        .package(
            name: "HTTPClient",
            url: "https://github.com/marinofelipe/http_client",
            .upToNextMinor(from: "0.0.4")
        )
    ],
    targets: [
        .target(
            name: "Run",
            dependencies: [
                .target(name: "App"),
                .target(name: "Reports"),
                .target(name: "Core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core")
            ]
        ),
        .testTarget(
            name: "RunTests",
            dependencies: [
                .target(name: "Run")
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                .product(name: "XcodeProj", package: "XcodeProj"),
                .product(name: "CombineHTTPClient", package: "HTTPClient"),
                .target(name: "Core")
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App")
            ]
        ),
        .target(
            name: "Reports",
            dependencies: [
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .target(name: "Core")
            ]
        ),
        .testTarget(
            name: "ReportsTests",
            dependencies: [
                .target(name: "Reports")
            ]
        ),
        .target(
            name: "Core",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                .target(name: "Core"),
                .target(name: "TestSupport")
            ],
            resources: [
                .copy("Resources/package_full.json")
            ]
        ),
        .target(
            name: "TestSupport",
            dependencies: []
        )
    ]
)
