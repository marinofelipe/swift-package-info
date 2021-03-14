//
//  PlatformsProviderTests.swift
//  
//
//  Created by Marino Felipe on 14.03.21.
//

import XCTest
import CoreTestSupport

@testable import App
@testable import Core

final class PlatformsProviderTests: XCTestCase {
    func testFetchInformation() throws {
        let result = PlatformsProvider.fetchInformation(
            for: Fixture.makeSwiftPackage(),
            packageContent: Fixture.makePackageContent(
                platforms: [
                    Fixture.makePackageContentPlatform(),
                    Fixture.makePackageContentPlatform(
                        platformName: "macos",
                        version: "10.15"
                    ),
                    Fixture.makePackageContentPlatform(
                        platformName: "watchos",
                        version: "7.3.2"
                    ),
                    Fixture.makePackageContentPlatform(
                        platformName: "tvos",
                        version: "14.0"
                    ),
                ]
            ),
            verbose: true
        )

        let providedInfo = try result.get()

        let expectedPlatformMessage: (String) -> ConsoleMessage = { contentText in
            ConsoleMessage(
                text: contentText,
                color: .noColor,
                isBold: true,
                hasLineBreakAfter: false
            )
        }
        let expectedSeparatorMessage = ConsoleMessage(
            text: " | ",
            hasLineBreakAfter: false
        )
        XCTAssertEqual(
            providedInfo.messages,
            [
                expectedPlatformMessage("ios from v. 13.5"),
                expectedSeparatorMessage,
                expectedPlatformMessage("macos from v. 10.15"),
                expectedSeparatorMessage,
                expectedPlatformMessage("watchos from v. 7.3.2"),
                expectedSeparatorMessage,
                expectedPlatformMessage("tvos from v. 14.0")
            ]
        )

        let encodedProvidedInfo = try JSONEncoder().encode(providedInfo)
        let encodedProvidedInfoString = String(
            data: encodedProvidedInfo,
            encoding: .utf8
        )

        XCTAssertEqual(
            encodedProvidedInfoString,
            #"{"macOS":"10.15","tvOS":"14.0","iOS":"13.5","watchOS":"7.3.2"}"#
        )
    }
}
