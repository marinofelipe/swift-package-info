// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-package-info",
  platforms: [
    .macOS(.v12)
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
    // - For now pinned to the 5.9.2 release / Xcode 15.1
    // It auto exports SwiftToolsSupport, so no need to directly depend on the former 🙏
    .package(
      url: "https://github.com/apple/swift-package-manager",
      revision: "swift-5.9.2-RELEASE"
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
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    ),
    .testTarget(
      name: "RunTests",
      dependencies: [
        .target(name: "Run")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    ),
    .target(
      name: "SwiftPackageInfo", // Library
      dependencies: [
        .target(name: "App"),
        .target(name: "Core")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    ),
    .testTarget(
      name: "SwiftPackageInfoTests",
      dependencies: [
        .target(name: "SwiftPackageInfo"),
        .target(name: "CoreTestSupport")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
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
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
        .target(name: "CoreTestSupport")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    ),
    .target(
      name: "Reports",
      dependencies: [
        .target(name: "Core")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    ),
    .testTarget(
      name: "ReportsTests",
      dependencies: [
        .target(name: "Reports"),
        .target(name: "CoreTestSupport")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    ),
    .target(
      name: "Core",
      dependencies: [
        .product(
          name: "ArgumentParser",
          package: "swift-argument-parser"
        ),
        .product(
          name: "SwiftPM",
          package: "swift-package-manager"
        ),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    ),
    .testTarget(
      name: "CoreTests",
      dependencies: [
        .target(name: "Core"),
        .target(name: "CoreTestSupport")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    ),
    .target(
      name: "CoreTestSupport",
      dependencies: [
        .target(name: "Core")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("InferSendableFromCaptures"),
      ]
    )
  ]
)

// TODO: For lib
// - Extract most out to the `App Target`
// - Provide API for both a simple struct definition and passing a ready Package(Model)
// - Remodel de report part, which has to return data for the consumer of the lib
// - Consider App Target split
