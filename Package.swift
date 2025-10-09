// swift-tools-version:6.2
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
      .upToNextMinor(from: "1.6.1")
    ),
    .package(
      url: "https://github.com/tuist/XcodeProj.git",
      .upToNextMinor(from: "8.7.1")
    ),
    .package(
      url: "https://github.com/marinofelipe/http_client",
      .upToNextMinor(from: "0.0.4")
    ),
    // - Pinned to the the Swift 6.2 development / Xcode 26
    // It auto exports SwiftToolsSupport, so no need to directly depend it 🙏
    .package(
      url: "https://github.com/apple/swift-package-manager",
      revision: "swift-6.2-DEVELOPMENT-SNAPSHOT-2025-10-01-a"
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
      ],
      swiftSettings: [
        .defaultIsolation(MainActor.self)
      ]
    ),
    .testTarget(
      name: "RunTests",
      dependencies: [
        .target(name: "Run")
      ],
      swiftSettings: [
//        .defaultIsolation(MainActor.self)
      ]
    ),
    .target(
      name: "SwiftPackageInfo", // Library
      dependencies: [
        .target(name: "App"),
        .target(name: "Core")
      ],
      swiftSettings: [
        .defaultIsolation(MainActor.self)
      ]
    ),
    .testTarget(
      name: "SwiftPackageInfoTests",
      dependencies: [
        .target(name: "SwiftPackageInfo"),
        .target(name: "CoreTestSupport")
      ],
      swiftSettings: [
//        .defaultIsolation(MainActor.self)
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
      ],
      swiftSettings: [
        .defaultIsolation(MainActor.self)
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
        .target(name: "CoreTestSupport")
      ],
      swiftSettings: [
//        .defaultIsolation(MainActor.self)
      ]
    ),
    .target(
      name: "Reports",
      dependencies: [
        .target(name: "Core")
      ],
      swiftSettings: [
        .defaultIsolation(MainActor.self)
      ]
    ),
    .testTarget(
      name: "ReportsTests",
      dependencies: [
        .target(name: "Reports"),
        .target(name: "CoreTestSupport")
      ],
      swiftSettings: [
//        .defaultIsolation(MainActor.self)
      ]
    ),
    .target(
      name: "Core",
      dependencies: [
        .product(
          name: "SwiftPM",
          package: "swift-package-manager"
        ),
      ],
      swiftSettings: [
        .defaultIsolation(MainActor.self)
      ]
    ),
    .testTarget(
      name: "CoreTests",
      dependencies: [
        .target(name: "Core"),
        .target(name: "CoreTestSupport")
      ],
      swiftSettings: [
//        .defaultIsolation(MainActor.self)
      ]
    ),
    .target(
      name: "CoreTestSupport",
      dependencies: [
        .target(name: "Core")
      ],
      swiftSettings: [
        .defaultIsolation(MainActor.self)
      ]
    )
  ],
  swiftLanguageModes: [
    .v5,
    .v6
  ]
)
