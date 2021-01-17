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
            "name": "0.2.4",
            "zipball_url": "https://api.github.com/repos/nerdishbynature/octokit.swift/zipball/0.2.4",
            "tarball_url": "https://api.github.com/repos/nerdishbynature/octokit.swift/tarball/0.2.4",
            "commit": {
              "sha": "733f6f7ee4a86eb6c0371fb6b6a2c88b95d05fe8",
              "url": "https://api.github.com/repos/nerdishbynature/octokit.swift/commits/733f6f7ee4a86eb6c0371fb6b6a2c88b95d05fe8"
            },
            "node_id": "MDM6UmVmMjkxNTI4OTI6cmVmcy90YWdzLzAuMi40"
          },
          {
            "name": "0.2.3",
            "zipball_url": "https://api.github.com/repos/nerdishbynature/octokit.swift/zipball/0.2.3",
            "tarball_url": "https://api.github.com/repos/nerdishbynature/octokit.swift/tarball/0.2.3",
            "commit": {
              "sha": "786a65fec263c8308672c481175ef5980d4f2d8e",
              "url": "https://api.github.com/repos/nerdishbynature/octokit.swift/commits/786a65fec263c8308672c481175ef5980d4f2d8e"
            },
            "node_id": "MDM6UmVmMjkxNTI4OTI6cmVmcy90YWdzLzAuMi4z"
          }
        ]
        """

        let encodedJSON = try XCTUnwrap(jsonString.data(using: .utf8))
        let tagsResponse = try jsonDecoder.decode(TagsResponse.self, from: encodedJSON)

        XCTAssertEqual(
            tagsResponse,
            .init(
                tags: [
                    .init(name: "0.2.4"),
                    .init(name: "0.2.3")
                ]
            )
        )
    }
}
