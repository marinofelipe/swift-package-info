//
//  PackageContentTests.swift
//
//
//  Created by Marino Felipe on 29.12.20.
//

import XCTest
import TestSupport
@testable import Core

final class PackageContentTests: XCTestCase {
    private let jsonDecoder: JSONDecoder = .init()

    func testDecodingFromJSON() throws {
        let fixtureData = try dataFromJSON(named: "package_full", bundle: .module)
        let packageContent = try jsonDecoder.decode(PackageContent.self, from: fixtureData)

        let expectedPackageContent = PackageContent(
            name: "SomePackage",
            platforms: [
                .init(
                    platformName: "ios",
                    version: "9.0"
                ),
                .init(
                    platformName: "macos",
                    version: "10.15"
                )
            ],
            products: [
                .init(
                    name: "Product1",
                    targets: [
                        "Target1",
                        "Target2"
                    ],
                    kind: .library(.automatic)
                ),
                .init(
                    name: "Product2",
                    targets: [
                        "Target1",
                        "Target3"
                    ],
                    kind: .library(.static)
                ),
                .init(
                    name: "Product3",
                    targets: [
                        "Target2"
                    ],
                    kind: .executable
                ),
                .init(
                    name: "Product4",
                    targets: [
                        "Target1"
                    ],
                    kind: .library(.dynamic)
                )
            ],
            dependencies: [
                .init(
                    name: "swift-argument-parser",
                    urlString: "https://github.com/apple/swift-argument-parser",
                    requirement: .init(
                        range: [
                            .init(
                                lowerBound: "0.3.0",
                                upperBound: "0.4.0"
                            )
                        ]
                    )
                )
            ],
            targets: [
                .init(
                    name: "Target1",
                    dependencies: [
                        .product(["swift-argument-parser"])
                    ],
                    kind: .regular
                ),
                .init(
                    name: "Target2",
                    dependencies: [
                        .byName(["Target1"])
                    ],
                    kind: .regular
                ),
                .init(
                    name: "Target3",
                    dependencies: [
                        .product(["ArgumentParser", "swift-argument-parser"]),
                        .target(["Target1"])
                    ],
                    kind: .test
                )
            ],
            swiftLanguageVersions: [
                "5"
            ]
        )

        XCTAssertEqual(
            packageContent,
            expectedPackageContent
        )
    }
}
