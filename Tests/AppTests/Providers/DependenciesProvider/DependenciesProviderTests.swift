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

final class DependenciesProviderTests: XCTestCase {
  func testWithTransitiveDependencies() throws {
    let productName = "Some"

    let target3 = PackageWrapper.Target(
      name: "Target3",
      dependencies: [
        .product(
          .init(
            name: "dependency-2",
            package: "dependency-2",
            isDynamicLibrary: false,
            targets: []
          )
        ),
        .product(
          .init(
            name: "dependency-3",
            package: "dependency-3",
            isDynamicLibrary: false,
            targets: []
          )
        )
      ]
    )

    let target2 = PackageWrapper.Target(
      name: "Target2",
      dependencies: [
        .product(
          .init(
            name: "dependency-2",
            package: "dependency-2",
            isDynamicLibrary: false,
            targets: []
          )
        ),
        .target(target3)
      ]
    )

    let target1 = PackageWrapper.Target(
      name: "Target1",
      dependencies: [
        .product(
          .init(
            name: "dependency-1",
            package: "dependency-1",
            isDynamicLibrary: false,
            targets: []
          )
        ),
        .target(target2)
      ]
    )

    let result = DependenciesProvider.fetchInformation(
      for: Fixture.makeSwiftPackage(
        product: productName
      ),
      package: Fixture.makePackageWrapper(
        products: [
          .init(
            name: productName,
            package: nil,
            isDynamicLibrary: nil,
            targets: [
              target1
            ]
          )
        ],
        targets: [
          target1,
          target2,
          target3
        ]
      ), xcconfig: nil,
      verbose: true
    )

    let providedInfo = try result.get()
    XCTAssertEqual(
      providedInfo.providerName,
      "Dependencies"
    )

    XCTAssertEqual(
      providedInfo.messages,
      [
        .init(
          text: "dependency-1",
          hasLineBreakAfter: false
        ),
        .init(
          text: " | ",
          hasLineBreakAfter: false
        ),
        .init(
          text: "dependency-2",
          hasLineBreakAfter: false
        ),
        .init(
          text: " | ",
          hasLineBreakAfter: false
        ),
        .init(
          text: "dependency-3",
          hasLineBreakAfter: false
        ),
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
      [
        {
          "package" : "dependency-1",
          "product" : "dependency-1"
        },
        {
          "package" : "dependency-2",
          "product" : "dependency-2"
        },
        {
          "package" : "dependency-3",
          "product" : "dependency-3"
        }
      ]
      """#
    )
  }

  func testWithMoreThan3ExternalDependencies() throws {
    let productName = "Some"

    let target = PackageWrapper.Target(
      name: "Target1",
      dependencies: [
        .product(
          .init(
            name: "dependency-1",
            package: "dependency-1",
            isDynamicLibrary: false,
            targets: []
          )
        ),
        .product(
          .init(
            name: "dependency-2",
            package: "dependency-2",
            isDynamicLibrary: false,
            targets: []
          )
        ),
        .product(
          .init(
            name: "dependency-3",
            package: "dependency-3",
            isDynamicLibrary: false,
            targets: []
          )
        ),
        .product(
          .init(
            name: "dependency-4",
            package: "dependency-4",
            isDynamicLibrary: false,
            targets: []
          )
        ),
      ]
    )

    let result = DependenciesProvider.fetchInformation(
      for: Fixture.makeSwiftPackage(
        product: productName
      ),
      package: Fixture.makePackageWrapper(
        products: [
          .init(
            name: productName,
            package: nil,
            isDynamicLibrary: nil,
            targets: [
              target
            ]
          )
        ],
        targets: [
          target
        ]
      ), 
      xcconfig: nil,
      verbose: true
    )

    let providedInfo = try result.get()
    XCTAssertEqual(
      providedInfo.providerName,
      "Dependencies"
    )

    XCTAssertEqual(
      providedInfo.messages,
      [
        .init(
          text: "dependency-1",
          hasLineBreakAfter: false
        ),
        .init(
          text: " | ",
          hasLineBreakAfter: false
        ),
        .init(
          text: "dependency-2",
          hasLineBreakAfter: false
        ),
        .init(
          text: " | ",
          hasLineBreakAfter: false
        ),
        .init(
          text: "dependency-3",
          hasLineBreakAfter: false
        ),
        .init(
          text: " | ",
          hasLineBreakAfter: false
        ),
        .init(
          text: "Use `--report jsonDump` to see all..",
          hasLineBreakAfter: false
        ),
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
      [
        {
          "package" : "dependency-1",
          "product" : "dependency-1"
        },
        {
          "package" : "dependency-2",
          "product" : "dependency-2"
        },
        {
          "package" : "dependency-3",
          "product" : "dependency-3"
        },
        {
          "package" : "dependency-4",
          "product" : "dependency-4"
        }
      ]
      """#
    )
  }
}
