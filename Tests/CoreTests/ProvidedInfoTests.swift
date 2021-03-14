//
//  ProvidedInfoTests.swift
//
//
//  Created by Marino Felipe on 14.03.21.
//

import XCTest
@testable import Core

final class ProvidedInfoTests: XCTestCase {
    private struct ProvidedContent: CustomConsoleMessagesConvertible, Encodable {
        let binarySize: Float
        var messages: [ConsoleMessage] {
            [
                .init(stringLiteral: "something")
            ]
        }
    }

    func testConsoleMessages() {
        let sut = ProvidedInfo(
            providerName: "name",
            information: ProvidedContent(binarySize: 300)
        )

        XCTAssertEqual(
            sut.messages,
            [
                .init(stringLiteral: "something")
            ]
        )
    }

    func testProviderName() {
        let sut = ProvidedInfo(
            providerName: "name",
            information: ProvidedContent(binarySize: 300)
        )

        XCTAssertEqual(
            sut.providerName,
            "name"
        )
    }

    func testEncodedValue() throws {
        let sut = ProvidedInfo(
            providerName: "name",
            information: ProvidedContent(binarySize: 300)
        )

        let encoded = try JSONEncoder().encode(sut)
        let encodedString = String(data: encoded, encoding: .utf8)

        XCTAssertEqual(
            encodedString,
            #"{"binarySize":300}"#
        )
    }
}
