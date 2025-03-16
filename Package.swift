// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-package-info",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .executable(
      name: "swift-package-info",
      targets: [
        "Run"
      ]
    ),
    .library(
      name: "SwiftPackageInfo",
      targets: ["SwiftPackageInfo"]
    )
  ],
  dependencies: [
    // Can't update and benefit from latest Swift 6 warnings fixes because the latest
    // swift-package-manager release still relies on older versions of the swift-argument-parser
    .package(
      url: "https://github.com/apple/swift-argument-parser",
      .upToNextMinor(from: "1.2.1")
    ),
    .package(
      url: "https://github.com/tuist/XcodeProj.git",
      .upToNextMinor(from: "8.7.1")
    ),
    .package(
      url: "https://github.com/marinofelipe/http_client",
      .upToNextMinor(from: "0.0.4")
    ),
    // - Pinned to the the Swift 6.0.3 release / Xcode 16.2
    // It auto exports SwiftToolsSupport, so no need to directly depend it 🙏
    .package(
      url: "https://github.com/apple/swift-package-manager",
      revision: "swift-6.0.3-RELEASE"
    ),
  ],
  targets: [
    .executableTarget(
      name: "Run",
      dependencies: [
        .target(name: "App"),
        .target(name: "Reports"),
        .target(name: "Core"),
        .product(
          name: "ArgumentParser",
          package: "swift-argument-parser"
        ),
      ]
    ),
    .testTarget(
      name: "RunTests",
      dependencies: [
        .target(name: "Run")
      ]
    ),
    .target(
      name: "SwiftPackageInfo", // Library
      dependencies: [
        .target(name: "App"),
        .target(name: "Core")
      ]
    ),
    .testTarget(
      name: "SwiftPackageInfoTests",
      dependencies: [
        .target(name: "SwiftPackageInfo"),
        .target(name: "CoreTestSupport")
      ]
    ),
    .target(
      name: "App",
      dependencies: [
        .product(
          name: "XcodeProj",
          package: "XcodeProj"
        ),
        .product(
          name: "CombineHTTPClient",
          package: "http_client"
        ),
        .target(name: "Core")
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
        .target(name: "CoreTestSupport")
      ]
    ),
    .target(
      name: "Reports",
      dependencies: [
        .target(name: "Core")
      ]
    ),
    .testTarget(
      name: "ReportsTests",
      dependencies: [
        .target(name: "Reports"),
        .target(name: "CoreTestSupport")
      ]
    ),
    .target(
      name: "Core",
      dependencies: [
        .product(
          name: "SwiftPM",
          package: "swift-package-manager"
        ),
      ]
    ),
    .testTarget(
      name: "CoreTests",
      dependencies: [
        .target(name: "Core"),
        .target(name: "CoreTestSupport")
      ]
    ),
    .target(
      name: "CoreTestSupport",
      dependencies: [
        .target(name: "Core")
      ]
    )
  ],
  swiftLanguageModes: [
    .v6
  ]
)
