//
//  FileManager+CoreTests.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import Foundation

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
        content data: Data
    ) throws {
        if fileExists(atPath: path) == false {
            createFile(atPath: path, contents: data, attributes: nil)
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
