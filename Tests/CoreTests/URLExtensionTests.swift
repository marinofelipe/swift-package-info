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
@testable import Core

final class URLExtensionTests: XCTestCase {
    enum TestFile: String, CaseIterable {
        case file
        case file1
    }

    private var fileManager: FileManager! = .default
    private lazy var temporaryTestDirectoryPath: String = fileManager.currentDirectoryPath.appending("/TemporaryTest")
    private lazy var temporaryTestDirectoryURL: URL = URL(fileURLWithPath: temporaryTestDirectoryPath)
    private lazy var defaultTestFileURL: URL = makeTestFileURL()

    override func setUpWithError() throws {
        try super.setUpWithError()

        try fileManager.createDirectory(atPath: temporaryTestDirectoryPath)
    }

    override func tearDownWithError() throws {
        try fileManager.removeItem(atPath: temporaryTestDirectoryPath)
        fileManager = nil

        try super.tearDownWithError()
    }

    func testByteCountFormatter() {
        let sut = URL.fileByteCountFormatter
        XCTAssertEqual(sut.countStyle, .file)
    }

    func testTotalFileAllocatedSize() throws {
        try createTestFile(atPath: defaultTestFileURL.path)

        XCTAssertEqual(try defaultTestFileURL.totalFileAllocatedSize(), 4096)
    }

    func testIsDirectoryForFile() throws {
        try createTestFile(atPath: defaultTestFileURL.path)

        XCTAssertFalse(try defaultTestFileURL.isDirectory())
    }

    func testIsDirectoryForDirectory() throws {
        XCTAssertTrue(try temporaryTestDirectoryURL.isDirectory())
    }

    func testDirectoryTotalAllocatedSizeIncludingSubfolders() throws {
        // create a file
        try createTestFile(atPath: defaultTestFileURL.path)

        // then
        XCTAssertEqual(
            try temporaryTestDirectoryURL.directoryTotalAllocatedSize(includingSubfolders: true),
            4096
        )

        // create a subfolder
        let subDirectoryURL = URL(
            fileURLWithPath: temporaryTestDirectoryPath
                .appending("/Subdirectory")
        )
        try fileManager.createDirectory(atPath: subDirectoryURL.path)

        // Add a file to the subfolder
        try createTestFile(
            atPath: makeTestFileURL(directoryURL: subDirectoryURL, componentName: TestFile.file1.rawValue).path,
            content: String(repeating: "1", count: 5_000).data(using: .utf8)!
        )

        // create another file to the main folder
        try createTestFile(
            atPath: makeTestFileURL(componentName: TestFile.file1.rawValue).path,
            content: String(repeating: "1", count: 5_000).data(using: .utf8)!
        )

        // then
        XCTAssertEqual(
            try temporaryTestDirectoryURL.directoryTotalAllocatedSize(includingSubfolders: true),
            20480
        )
    }

    func testDirectoryTotalAllocatedSizeWithoutIncludingSubfolders() throws {
        // create a file
        try createTestFile(atPath: defaultTestFileURL.path)

        // then
        XCTAssertEqual(
            try temporaryTestDirectoryURL.directoryTotalAllocatedSize(includingSubfolders: false),
            4096
        )

        // create a subfolder
        let subDirectoryURL = URL(
            fileURLWithPath: temporaryTestDirectoryPath
                .appending("/Subdirectory")
        )
        try fileManager.createDirectory(atPath: subDirectoryURL.path)

        // Add a file to the subfolder
        try createTestFile(
            atPath: makeTestFileURL(directoryURL: subDirectoryURL, componentName: TestFile.file1.rawValue).path,
            content: String(repeating: "1", count: 5_000).data(using: .utf8)!
        )

        // create another file to the main folder
        try createTestFile(
            atPath: makeTestFileURL(componentName: TestFile.file1.rawValue).path,
            content: String(repeating: "1", count: 5_000).data(using: .utf8)!
        )

        // then
        XCTAssertEqual(
            try temporaryTestDirectoryURL.directoryTotalAllocatedSize(includingSubfolders: false),
            12288
        )
    }

    func testSizeOnDiskForFile() throws {
        try createTestFile(atPath: defaultTestFileURL.path)

        XCTAssertEqual(
            try defaultTestFileURL.sizeOnDisk(),
            .init(amount: 4096, formatted: "4 KB")
        )
    }

    func testSizeOnDiskForDirectory() throws {
        // Check initial directory size
        XCTAssertEqual(
            try temporaryTestDirectoryURL.sizeOnDisk(),
            .init(amount: 0, formatted: "Zero KB")
        )

        // Create a new file in temporaryDirectory
        try createTestFile(
            atPath: defaultTestFileURL.path,
            content: String(repeating: "1", count: 500_000).data(using: .utf8)!
        )

        // Then
        XCTAssertEqual(
            try temporaryTestDirectoryURL.sizeOnDisk(),
            .init(amount: 503808, formatted: "504 KB")
        )
    }

    // MARK: Tests - isValidLocalDirectory

    func testIsValidLocalDirectoryWhenDoesNotContainPackageDotSwift() throws {
        let subDirectoryURL = URL(
            fileURLWithPath: fileManager.currentDirectoryPath
                .appending("/directory")
        )

        // Create subdirectory
        try fileManager.createDirectory(atPath: subDirectoryURL.path)

        // Then
        let relativeURL = URL(string: "directory")!
        XCTAssertFalse(try relativeURL.isLocalDirectoryContainingPackageDotSwift())

        // Clean up subdirectory
        if fileManager.fileExists(atPath: subDirectoryURL.path) {
            try fileManager.removeItem(atPath: subDirectoryURL.path)
        }
    }

    func testIsValidLocalDirectoryWhenContainsPackageDotSwift() throws {
        let subDirectoryURL = URL(
            fileURLWithPath: fileManager.currentDirectoryPath
                .appending("/directory")
        )

        // Create a subdirectory
        try fileManager.createDirectory(atPath: subDirectoryURL.path)

        // Create a Package.swift file on it
        try fileManager.createFile(
            atPath: subDirectoryURL.path + "/Package.swift",
            content: "some-data".data(using: .utf8)!
        )

        // Then
        let relativeURL = URL(string: "directory")!
        XCTAssertTrue(try relativeURL.isLocalDirectoryContainingPackageDotSwift())

        // Clean up subdirectory
        if fileManager.fileExists(atPath: subDirectoryURL.path) {
            try fileManager.removeItem(atPath: subDirectoryURL.path)
        }
    }

    // MARK: Tests - isValidRemote

    func testIsValidRemote() throws {
        var url = try XCTUnwrap(
            URL(string: "https://www.bla.bla")
        )
        XCTAssertTrue(url.isValidRemote)

        url = try XCTUnwrap(
            URL(string: "http://bla.bla")
        )
        XCTAssertTrue(url.isValidRemote)

        url = try XCTUnwrap(
            URL(string: "htt://bla.bla")
        )
        XCTAssertFalse(url.isValidRemote)

        url = try XCTUnwrap(
            URL(string: "https://bla")
        )
        XCTAssertFalse(url.isValidRemote)
    }
}

// MARK: - Helpers

private extension URLExtensionTests {
    func makeTestFileURL(
        componentName: String = TestFile.file.rawValue
    ) -> URL {
        temporaryTestDirectoryURL
            .appendingPathComponent(componentName)
            .appendingPathExtension("txt")
    }

    func makeTestFileURL(
        directoryURL: URL,
        componentName: String = TestFile.file.rawValue
    ) -> URL {
        directoryURL
            .appendingPathComponent(componentName)
            .appendingPathExtension("txt")
    }

    func createTestFile(
        atPath path: String,
        content fakeData: Data = String(repeating: "1", count: 1_000).data(using: .utf8)!
    ) throws {
        try fileManager.createFile(atPath: path, content: fakeData)
    }
}
