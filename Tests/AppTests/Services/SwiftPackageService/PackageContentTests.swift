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
        let jsonString = """
        {
          "cLanguageStandard" : null,
          "cxxLanguageStandard" : null,
          "dependencies" : [

          ],
          "name" : "CurrencyText",
          "pkgConfig" : null,
          "platforms" : [
            {
              "options" : [

              ],
              "platformName" : "ios",
              "version" : "9.0"
            }
          ],
          "products" : [
            {
              "name" : "CurrencyText",
              "targets" : [
                "CurrencyFormatter",
                "CurrencyUITextFieldDelegate"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ],
          "providers" : null,
          "swiftLanguageVersions" : null,
          "targets" : [
            {
              "dependencies" : [

              ],
              "exclude" : [

              ],
              "name" : "CurrencyFormatter",
              "path" : "Sources Formatter",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "regular"
            },
            {
              "dependencies" : [
                {
                  "byName" : [
                    "CurrencyFormatter",
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "CurrencyUITextFieldDelegate",
              "path" : "Sources UITextFieldDelegate",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "regular"
            },
            {
              "dependencies" : [
                {
                  "byName" : [
                    "CurrencyFormatter",
                    null
                  ]
                },
                {
                  "byName" : [
                    "CurrencyUITextFieldDelegate",
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "Tests",
              "path" : "Tests",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "test"
            }
          ],
          "toolsVersion" : {
            "_version" : "5.0.0"
          }
        }
        """

        let encodedJSON = try XCTUnwrap(jsonString.data(using: .utf8))
        let packageContent = try jsonDecoder.decode(PackageContent.self, from: encodedJSON)

        XCTAssertEqual(
            packageContent,
            .init(
                name: "CurrencyText",
                products: [
                    .init(name: "CurrencyText")
                ]
            )
        )
    }

    func testDecodingFromJSONThatHasMultipleProducts() throws {
        let jsonString = """
        {
          "cLanguageStandard" : null,
          "cxxLanguageStandard" : null,
          "dependencies" : [

          ],
          "name" : "CurrencyText",
          "pkgConfig" : null,
          "platforms" : [
            {
              "options" : [

              ],
              "platformName" : "ios",
              "version" : "9.0"
            }
          ],
          "products" : [
            {
              "name" : "CurrencyText",
              "targets" : [
                "CurrencyFormatter",
                "CurrencyUITextFieldDelegate"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            },
            {
              "name" : "AnotherProduct",
              "targets" : [
                "CurrencyFormatter",
                "CurrencyUITextFieldDelegate"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ]
        }
        """

        let encodedJSON = try XCTUnwrap(jsonString.data(using: .utf8))
        let packageContent = try jsonDecoder.decode(PackageContent.self, from: encodedJSON)

        XCTAssertEqual(
            packageContent,
            .init(
                name: "CurrencyText",
                products: [
                    .init(name: "CurrencyText"),
                    .init(name: "AnotherProduct"),
                ]
            )
        )
    }
}
