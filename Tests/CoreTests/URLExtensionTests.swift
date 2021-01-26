//
//  URLExtensionTests.swift
//
//
//  Created by Marino Felipe on 29.12.20.
//

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
