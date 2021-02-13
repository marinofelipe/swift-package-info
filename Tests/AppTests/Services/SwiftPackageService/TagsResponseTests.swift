//
//  TagsResponseTests.swift
//
//
//  Created by Marino Felipe on 29.12.20.
//

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
