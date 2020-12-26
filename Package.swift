// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-package-info",
    products: [
        .library(
            name: "SwiftPackageInfo",
            targets: ["SwiftPackageInfo"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "SwiftPackageInfo",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "SwiftPackageInfoTests",
            dependencies: ["SwiftPackageInfo"]
        )
    ]
)
