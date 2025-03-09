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

@testable import Core

final class SwiftPackageTests: XCTestCase {
  // MARK: - Init

  func testResolutionPermutations() throws {
    struct Permutation: Equatable {
      let version: String
      let revision: String?
      let expectedResolution: PackageDefinition.Resolution
    }

    let permutations = [
      Permutation(
        version: "1.2.3",
        revision: "3fag5v0",
        expectedResolution: .version("1.2.3")
      ),
      Permutation(
        version: ResourceState.undefined.description,
        revision: nil,
        expectedResolution: .version(ResourceState.undefined.description)
      ),
      Permutation(
        version: ResourceState.undefined.description, 
        revision: "3fag5v0",
        expectedResolution: .revision("3fag5v0")
      ),
      Permutation(
        version: ResourceState.invalid.description,
        revision: "3fag5v0",
        expectedResolution: .version(ResourceState.invalid.description)
      ),
      Permutation(
        version: ResourceState.undefined.description, 
        revision: nil, 
        expectedResolution: .version(ResourceState.undefined.description)
      )
    ]

    try permutations.forEach { permutation in
      let sut = try Fixture.makeSwiftPackage(
        version: permutation.version,
        revision: permutation.revision
      )

      XCTAssertEqual(
        sut.resolution,
        permutation.expectedResolution
      )
    }
  }

  func testInvalidRemoteAndLocal() throws {
    XCTAssertThrowsError(
      try Fixture.makeSwiftPackage(
        url: URL(string: "../directory")!
      )
    )

    do {
      _ = try Fixture.makeSwiftPackage(
        url: URL(string: "../directory")!
      )
    } catch {
      XCTAssertEqual(error as? PackageDefinition.Error, .invalidURL)
    }
  }

  // MARK: - Description

  func testDescriptionWhenLocal() throws {
    let temporaryDir = createTemporaryValidLocalDir()
    let sut = try Fixture.makeSwiftPackage(url: temporaryDir)
    XCTAssertEqual(
      sut.description,
      """
      Local path: \(temporaryDir)
      Version: 1.0.0
      Product: Some
      """
    )
  }

  func testDescriptionWhenRemote() throws {
    let sut = try Fixture.makeSwiftPackage()
    XCTAssertEqual(
      sut.description,
      """
      Repository URL: https://www.apple.com
      Version: 1.0.0
      Product: Some
      """
    )
  }

  func testDescriptionWhenRevision() throws {
    let revision = "f46ab7s"
    let sut = try Fixture.makeSwiftPackage(
      version: ResourceState.undefined.description,
      revision: revision
    )
    XCTAssertEqual(
      sut.description,
      """
      Repository URL: https://www.apple.com
      Revision: \(revision)
      Product: Some
      """
    )
  }

  // MARK: - Account and repository

  func testAccountAndRepositoryNamesWhenLocal() throws {
    let temporaryDir = createTemporaryValidLocalDir()
    let sut = try Fixture.makeSwiftPackage(url: temporaryDir)

    XCTAssertTrue(sut.accountName.isEmpty)
    XCTAssertTrue(sut.repositoryName.isEmpty)
  }

  func testAccountAndRepositoryNamesWhenNotValidGitURL() throws {
    let sut = try Fixture.makeSwiftPackage(
      url: URL(string: "https://www.where.com")!
    )
    XCTAssertTrue(sut.accountName.isEmpty)
    XCTAssertTrue(sut.repositoryName.isEmpty)
  }

  func testAccountAndRepositoryNamesWhenRemoteValidGitURL() throws {
    let sut = try Fixture.makeSwiftPackage(
      url: URL(string: "https://www.github.com/erica/now")!
    )
    XCTAssertEqual(
      sut.accountName,
      "erica"
    )
    XCTAssertEqual(
      sut.repositoryName,
      "now"
    )
  }

  func testAccountAndRepositoryNamesWhenURLHasDotGitAtTheEnd() throws {
    let sut = try Fixture.makeSwiftPackage(
      url: URL(string: "https://www.github.com/erica/now.git")!
    )
    XCTAssertEqual(
      sut.accountName,
      "erica"
    )
    XCTAssertEqual(
      sut.repositoryName,
      "now"
    )
  }
}

private extension SwiftPackageTests {
  func createTemporaryValidLocalDir() -> URL {
    let temporaryDir = URL.temporaryDirectory
    let temporaryFilename = "Package.swift"
    let temporaryFileURL = temporaryDir.appendingPathComponent(temporaryFilename)

    try? FileManager.default.createFile(
      atPath: temporaryFileURL.path(),
      content: Data("Test".utf8)
    )

    return temporaryDir
  }
}
