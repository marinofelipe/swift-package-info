//
//  URL+SwiftPackageInfo.swift
//
//  Acknowledgement: This piece of code is inspired by StackOverflow post and top-voted answer on how to get directory size on OS X:
//  https://stackoverflow.com/questions/32814535/how-to-get-directory-size-with-swift-on-os-x
//
//  Created by Marino Felipe on 28.12.20.
//

import Foundation

struct SizeOnDisk: Equatable {
    let amount: Int
    let formatted: String

    static let empty: SizeOnDisk = .init(amount: 0, formatted: "0.0")
}

extension URL {
    static let fileByteCountFormatter: ByteCountFormatter = {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.countStyle = .file
        return byteCountFormatter
    }()

    func totalFileAllocatedSize() throws -> Int {
        try resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0
    }

    /// check if the URL is a directory and if it is reachable
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }

        return try checkResourceIsReachable()
    }

    /// returns total allocated size of a the directory including its subFolders or not
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

    /// returns the directory total size on disk
    func sizeOnDisk() throws -> SizeOnDisk {
        let size = try isDirectoryAndReachable()
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
