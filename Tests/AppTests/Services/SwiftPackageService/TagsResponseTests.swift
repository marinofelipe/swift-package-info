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
@testable import App

final class TagsResponseTests: XCTestCase {
    private let jsonDecoder: JSONDecoder = .init()

    func testDecodingFromJSON() throws {
        let jsonString = """
        [
          {
            "ref": "refs/tags/7.5.1",
            "node_id": "MDM6UmVmODkwMzM1NTY6cmVmcy90YWdzLzcuNS4x",
            "url": "https://api.github.com/repos/firebase/firebase-ios-sdk/git/refs/tags/7.5.1",
            "object": {
              "sha": "447cf74cc561d408bc66c0294145a624645038ac",
              "type": "commit",
               "url": "https://api.github.com/repos/firebase/firebase-ios-sdk/git/commits/447cf74cc561d408bc66c0294145a624645038ac"
            }
            },
            {
              "ref": "refs/tags/7.6.0",
              "node_id": "MDM6UmVmODkwMzM1NTY6cmVmcy90YWdzLzcuNi4w",
              "url": "https://api.github.com/repos/firebase/firebase-ios-sdk/git/refs/tags/7.6.0",
              "object": {
                "sha": "0dd2ad1054177670dfa5bb1bbc6767e2a965095d",
                "type": "commit",
                "url": "https://api.github.com/repos/firebase/firebase-ios-sdk/git/commits/0dd2ad1054177670dfa5bb1bbc6767e2a965095d"
              }
            }
        ]
        """

        let encodedJSON = try XCTUnwrap(jsonString.data(using: .utf8))
        let tagsResponse = try jsonDecoder.decode(TagsResponse.self, from: encodedJSON)

        XCTAssertEqual(
            tagsResponse,
            .init(
                tags: [
                    .init(name: "refs/tags/7.5.1"),
                    .init(name: "refs/tags/7.6.0")
                ]
            )
        )
    }
}
