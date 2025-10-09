//  Copyright (c) 2025 Felipe Marino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import XCTest
@testable import Core

@MainActor
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
      providerKind: .binarySize,
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
      providerKind: .binarySize,
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
      providerKind: .binarySize,
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
