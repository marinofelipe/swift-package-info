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
      package: Fixture.makePackageWrapper(
        products: [
          .init(
            name: productName,
            package: nil,
            isDynamicLibrary: true,
            targets: [
              .init(
                name: "Target",
                dependencies: []
              )
            ]
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

    let encodedProvidedInfo = try JSONEncoder.sortedAndPrettyPrinted.encode(providedInfo)
    let encodedProvidedInfoString = String(
      data: encodedProvidedInfo,
      encoding: .utf8
    )

    XCTAssertEqual(
      encodedProvidedInfoString,
      #"""
      {
        "amount" : 908,
        "formatted" : "908 kb"
      }
      """#
    )
  }
}
