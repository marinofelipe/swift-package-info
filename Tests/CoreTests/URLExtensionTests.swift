import XCTest
@testable import SwiftPackageInfo

final class URLExtensionTests: XCTestCase {
    private var fileManager: FileManager! = .default
    private lazy var temporaryDirectoryURL: URL = fileManager.temporaryDirectory

    override func tearDown() {
        fileManager = nil
    }

    func testByteCountFormatter() {
        let sut = URL.fileByteCountFormatter
        XCTAssertEqual(sut.countStyle, .file)
    }

    func testTotalFileAllocatedSize() throws {
        let fileURL = temporaryDirectoryURL
            .appendingPathComponent("file")
            .appendingPathExtension("txt")

        let fakeData = try XCTUnwrap(
            String(repeating: "0", count: 500)
                .data(using: .utf8)
        )

        try fileManager.createFile(atPath: fileURL.path, for: fakeData)

        XCTAssertEqual(try fileURL.totalFileAllocatedSize(), 1)
    }

    static var allTests = [
        ("testByteCountFormatter", testByteCountFormatter),
    ]
}

// MARK: - Helpers

enum FileManagerError: LocalizedError {
    case fileAlreadyExists(atPath: String)
    case directoryAlreadyExists(atPath: String)

    var errorDescription: String? {
        switch self {
            case let .fileAlreadyExists(path):
                return "Unable to create file since file already exists at \(path)"
            case let .directoryAlreadyExists(path):
                return "Unable to directory since directory already exists at \(path)"
        }
    }
}

extension FileManager {
    func createFile(
        atPath path: String,
        for data: Data
    ) throws {
        if fileExists(atPath: path) == false {
            try createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } else {
            throw FileManagerError.fileAlreadyExists(atPath: path)
        }
    }

    func createDirectory(atPath path: String) throws {
        if fileExists(atPath: path) == false {
            try createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } else {
            throw FileManagerError.directoryAlreadyExists(atPath: path)
        }
    }
}
