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
    func testDescriptionWhenLocal() {
        let sut = Fixture.makeSwiftPackage(
            isLocal: true
        )
        XCTAssertEqual(
            sut.description,
            """
            Local path: https://www.apple.com
            Version: 1.0.0
            Product: Some
            """
        )
    }

    func testDescriptionWhenRemote() {
        let sut = Fixture.makeSwiftPackage(isLocal: false)
        XCTAssertEqual(
            sut.description,
            """
            Repository URL: https://www.apple.com
            Version: 1.0.0
            Product: Some
            """
        )
    }

    func testAccountAndRepositoryNamesWhenLocal() {
        let sut = Fixture.makeSwiftPackage(
            url: URL(string: "../directory")!,
            isLocal: true
        )
        XCTAssertTrue(sut.accountName.isEmpty)
        XCTAssertTrue(sut.repositoryName.isEmpty)
    }

    func testAccountAndRepositoryNamesWhenNotValidGitURL() {
        let sut = Fixture.makeSwiftPackage(
            url: URL(string: "https://www.where.com")!,
            isLocal: false
        )
        XCTAssertTrue(sut.accountName.isEmpty)
        XCTAssertTrue(sut.repositoryName.isEmpty)
    }

    func testAccountAndRepositoryNamesWhenRemoteValidGitURL() {
        let sut = Fixture.makeSwiftPackage(
            url: URL(string: "https://www.github.com/erica/now")!,
            isLocal: false
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

    func testAccountAndRepositoryNamesWhenURLHasDotGitAtTheEnd() {
        let sut = Fixture.makeSwiftPackage(
            url: URL(string: "https://www.github.com/erica/now.git")!,
            isLocal: false
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
