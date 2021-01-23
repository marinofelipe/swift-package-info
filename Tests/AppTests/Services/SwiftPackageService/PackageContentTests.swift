//
//  PackageContentTests.swift
//
//
//  Created by Marino Felipe on 29.12.20.
//

import XCTest
@testable import App

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
                    kind: .library(.dynamic)
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
                        .init(
                            target: nil,
                            product: [
                                "swift-argument-parser",
                                nil
                            ],
                            byName: nil
                        )
                    ],
                    kind: .regular
                ),
                .init(
                    name: "Target2",
                    dependencies: [
                        .init(
                            target: nil,
                            product: nil,
                            byName: [
                                "Target1",
                                nil
                            ]
                        )
                    ],
                    kind: .regular
                ),
                .init(
                    name: "Target3",
                    dependencies: [
                        .init(
                            target: nil,
                            product: [
                                "ArgumentParser",
                                "swift-argument-parser",
                                nil
                            ],
                            byName: nil
                        ),
                        .init(
                            target: [
                                "Target1",
                                nil
                            ],
                            product: nil,
                            byName: nil
                        )
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

extension XCTestCase {
    public func dataFromJSON(named name: String, bundle: Bundle, _ file: StaticString = #file, _ line: UInt = #line) throws -> Data {
        let jsonData = try bundle.url(forResource: name, withExtension: "json")
            .flatMap { try Data(contentsOf: $0) }
        return try XCTUnwrap(jsonData)
    }
}
