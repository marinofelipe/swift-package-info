import XCTest
@testable import Core

final class URLExtensionTests: XCTestCase {
    enum TestFile: String, CaseIterable {
        case file
        case file1
    }

    private var fileManager: FileManager! = .default
    private lazy var temporaryDirectoryURL: URL = fileManager.temporaryDirectory
    private lazy var defaultTestFileURL: URL = makeTestFileURL()

    override func tearDownWithError() throws {
        try TestFile.allCases.forEach { testFile in
            let testFileURL = makeTestFileURL(componentName: testFile.rawValue)
            if fileManager.fileExists(atPath: testFileURL.path) {
                try fileManager.removeItem(atPath: testFileURL.path)
            }
        }
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
        XCTAssertTrue(try temporaryDirectoryURL.isDirectory())
    }

    func testDirectoryTotalAllocatedSizeIncludingSubfolders() throws {
        // create a file
        try createTestFile(atPath: defaultTestFileURL.path)

        // then
        XCTAssertEqual(
            try temporaryDirectoryURL.directoryTotalAllocatedSize(includingSubfolders: true),
            77209600
        )

        // create another file
        try createTestFile(
            atPath: makeTestFileURL(componentName: TestFile.file1.rawValue).path,
            content: String(repeating: "1", count: 5_000).data(using: .utf8)!
        )

        // then
        XCTAssertEqual(
            try temporaryDirectoryURL.directoryTotalAllocatedSize(includingSubfolders: true),
            77217792
        )
    }

    func testDirectoryTotalAllocatedSizeWithoutIncludingSubfolders() throws {
        // create a file
        try createTestFile(atPath: defaultTestFileURL.path)

        // then
        XCTAssertEqual(
            try temporaryDirectoryURL.directoryTotalAllocatedSize(includingSubfolders: false),
            1224704
        )

        // create another file
        try createTestFile(
            atPath: makeTestFileURL(componentName: TestFile.file1.rawValue).path,
            content: String(repeating: "1", count: 5_000).data(using: .utf8)!
        )

        // then
        XCTAssertEqual(
            try temporaryDirectoryURL.directoryTotalAllocatedSize(includingSubfolders: false),
            1232896
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
            try temporaryDirectoryURL.sizeOnDisk(),
            .init(amount: 77205504, formatted: "77,2 MB")
        )

        // Create a new file in temporaryDirectory
        try createTestFile(
            atPath: defaultTestFileURL.path,
            content: String(repeating: "1", count: 500_000).data(using: .utf8)!
        )

        // Then
        XCTAssertEqual(
            try temporaryDirectoryURL.sizeOnDisk(),
            .init(amount: 77709312, formatted: "77,7 MB")
        )
    }

    static var allTests = [
        ("testByteCountFormatter", testByteCountFormatter),
        ("testTotalFileAllocatedSize", testTotalFileAllocatedSize),
        ("testIsDirectoryForFile", testIsDirectoryForFile),
        ("testIsDirectoryForDirectory", testIsDirectoryForDirectory),
        ("testDirectoryTotalAllocatedSizeIncludingSubfolders", testDirectoryTotalAllocatedSizeIncludingSubfolders),
        ("testDirectoryTotalAllocatedSizeWithoutIncludingSubfolders", testDirectoryTotalAllocatedSizeWithoutIncludingSubfolders),
        ("testSizeOnDiskForFile", testSizeOnDiskForFile),
        ("testSizeOnDiskForDirectory", testSizeOnDiskForDirectory)
    ]
}

// MARK: - Helpers

private extension URLExtensionTests {
    func makeTestFileURL(componentName: String = TestFile.file.rawValue) -> URL {
        temporaryDirectoryURL
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
