//
//  BinarySizeProviderTests.swift
//
//
//  Created by Marino Felipe on 14.03.21.
//

import XCTest
import CoreTestSupport

@testable import App
@testable import Core

final class BinarySizeProviderTests: XCTestCase {
    func testFetchInformation() throws {
        var defaultSizeMeasurerCallsCount = 0
        var lastVerbose: Bool?

        var sizeMeasurerCallsCount = 0
        var lastSwiftPackage: SwiftPackage?
        var lastIsDynamic: Bool?

        defaultSizeMeasurer = { verbose in
            lastVerbose = verbose
            defaultSizeMeasurerCallsCount += 1

            return { swiftPackage, isDynamic in
                lastSwiftPackage = swiftPackage
                lastIsDynamic = isDynamic
                sizeMeasurerCallsCount += 1

                return .init(
                    amount: 908,
                    formatted: "908 kb"
                )
            }
        }

        let productName = "Product"
        let swiftPackage = Fixture.makeSwiftPackage(
            product: productName
        )
        let result = BinarySizeProvider.fetchInformation(
            for: swiftPackage,
            packageContent: Fixture.makePackageContent(
                products: [
                    .init(
                        name: productName,
                        targets: ["Target"],
                        kind: .library(.dynamic)
                    )
                ]
            ),
            verbose: true
        )

        let providedInfo = try result.get()
        XCTAssertEqual(
            providedInfo.providerName,
            "Binary Size"
        )
        XCTAssertEqual(
            providedInfo.providerKind,
            .binarySize
        )

        XCTAssertEqual(
            defaultSizeMeasurerCallsCount,
            1
        )
        XCTAssertEqual(
            lastVerbose,
            true
        )
        XCTAssertEqual(
            sizeMeasurerCallsCount,
            1
        )
        XCTAssertEqual(
            lastSwiftPackage,
            swiftPackage
        )
        XCTAssertEqual(
            lastIsDynamic,
            true
        )

        XCTAssertEqual(
            providedInfo.messages,
            [
                ConsoleMessage(
                    text: "Binary size increases by ",
                    color: .noColor,
                    isBold: false,
                    hasLineBreakAfter: false
                ),
                ConsoleMessage(
                    text: "908 kb",
                    color: .yellow,
                    isBold: true,
                    hasLineBreakAfter: false
                )
            ]
        )

        let encodedProvidedInfo = try JSONEncoder().encode(providedInfo)
        let encodedProvidedInfoString = String(
            data: encodedProvidedInfo,
            encoding: .utf8
        )

        XCTAssertEqual(
            encodedProvidedInfoString,
            #"{"amount":908,"formatted":"908 kb"}"#
        )
    }
}
