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
import CoreTestSupport

@testable import App
@testable import Core

final class BinarySizeProviderTests: XCTestCase {
  func testFetchInformation() async throws {
    let sizeMeasurerMock = SizeMeasurerMock()
    sizeMeasurerMock.sizeStub = .init(
      amount: 908,
      formatted: "908 kb"
    )

    let productName = "Product"
    let swiftPackage = try Fixture.makePackageDefinition(
      product: productName
    )
    let providedInfo = try await BinarySizeProvider.binarySize(
      for: swiftPackage,
      resolvedPackage: Fixture.makePackageWrapper(
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
      xcconfig: nil,
      verbose: true
    )

    XCTAssertEqual(
      providedInfo.providerName,
      "Binary Size"
    )
    XCTAssertEqual(
      providedInfo.providerKind,
      .binarySize
    )

    XCTAssertEqual(
      sizeMeasurerMock.called.map(\.0),
      [
        swiftPackage
      ]
    )
    XCTAssertEqual(
      sizeMeasurerMock.called.map(\.1),
      [
        true
      ]
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

private final class SizeMeasurerMock: SizeMeasuring {
  private(set) var called: [(PackageDefinition, Bool)] = []
  var sizeStub: SizeOnDisk = .empty

  func binarySize(
    for swiftPackage: PackageDefinition,
    isDynamic: Bool
  ) async throws -> SizeOnDisk {
    called.append((swiftPackage, isDynamic))
    return sizeStub
  }
}
