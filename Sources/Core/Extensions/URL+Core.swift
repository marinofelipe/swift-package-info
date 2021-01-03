//
//  URL+Core.swift
//
//  Acknowledgement: This piece of code is inspired by StackOverflow post's top-voted answer on how to get directory size on OS X:
//  https://stackoverflow.com/questions/32814535/how-to-get-directory-size-with-swift-on-os-x
//
//  Created by Marino Felipe on 28.12.20.
//

import Foundation

// MARK: - Size on disk

extension URL {
    public static let fileByteCountFormatter: ByteCountFormatter = {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.countStyle = .file
        return byteCountFormatter
    }()

    func totalFileAllocatedSize() throws -> Int {
        try resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0
    }

    func isDirectory() throws -> Bool {
        try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true
    }

    func directoryTotalAllocatedSize(
        fileManager: FileManager = .default,
        includingSubfolders: Bool = false
    ) throws -> Int {
        let allocatedSizeWithoutSubfolders = {
            return try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).totalAllocatedSize()
        }

        if includingSubfolders {
            guard let urls = fileManager.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else {
                return try allocatedSizeWithoutSubfolders()
            }

            return try urls.totalAllocatedSize()
        }

        return try allocatedSizeWithoutSubfolders()
    }

    public func sizeOnDisk() throws -> SizeOnDisk {
        let size = try isDirectory()
            ? try directoryTotalAllocatedSize(includingSubfolders: true)
            : try totalFileAllocatedSize()

        guard let formattedByteCount = URL.fileByteCountFormatter.string(for: size) else {
            throw URLSizeReadingError.unableToCountCountBytes(filePath: self.path)
        }
        return .init(amount: size, formatted: formattedByteCount)
    }
}

enum URLSizeReadingError: LocalizedError {
    case unableToCountCountBytes(filePath: String)

    var errorDescription: String? {
        switch self {
            case let .unableToCountCountBytes(filePath):
                return "Unable to count bytes for file at: \(filePath)"
        }
    }
}

extension Array where Element == URL {
    func totalAllocatedSize() throws -> Int {
        try lazy.reduce(0) { try $1.totalFileAllocatedSize() + $0 }
    }
}

// MARK: - Extension: IsValid

public extension URL {
    static let isValidURLRegex = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"

    var isValid: Bool {
        NSPredicate(format:"SELF MATCHES %@", Self.isValidURLRegex)
            .evaluate(with: absoluteString)
    }
}

// MARK: - Extension: ExpressibleByArgument

import ArgumentParser

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(string: argument)
    }

    public var defaultValueDescription: String { "https://github.com/Alamofire/Alamofire" }
}
