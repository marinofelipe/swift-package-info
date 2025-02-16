//  Copyright (c) 2022 Felipe Marino
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
import CoreTestSupport

@testable import App
@testable import Core

final class PlatformsProviderTests: XCTestCase {
  func testFetchInformation() async throws {
    let providedInfo = try await PlatformsProvider.fetchInformation(
      for: Fixture.makeSwiftPackage(),
      package: Fixture.makePackageWrapper(
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
      xcconfig: nil,
      verbose: true
    )

    XCTAssertEqual(
      providedInfo.providerName,
      "Platforms"
    )
    XCTAssertEqual(
      providedInfo.providerKind,
      .platforms
    )

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

    let encodedProvidedInfo = try JSONEncoder.sortedAndPrettyPrinted.encode(providedInfo)
    let encodedProvidedInfoString = String(
      data: encodedProvidedInfo,
      encoding: .utf8
    )

    XCTAssertEqual(
      encodedProvidedInfoString,
      #"""
      {
        "iOS" : "13.5",
        "macOS" : "10.15",
        "tvOS" : "14.0",
        "watchOS" : "7.3.2"
      }
      """#
    )
  }
}
