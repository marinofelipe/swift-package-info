//
//  SwiftPackageTests.swift
//
//
//  Created by Marino Felipe on 29.12.20.
//

import XCTest
import CoreTestSupport

@testable import Core

final class SwiftPackageTests: XCTestCase {
    func testDescriptionWhenLocal() {
        let sut = Fixture.makeSwiftPackage(isLocal: true)
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
