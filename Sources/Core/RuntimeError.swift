//
//  RuntimeError.swift
//  
//
//  Created by Marino Felipe on 30.12.20.
//

import Foundation

enum RuntimeError: LocalizedError, Equatable {
    case unableToGetBinarySizeOnDisk(underlyingError: NSError)
    case unableToRetrieveAppProject(atPath: String)

    var errorDescription: String? {
        switch self {
            case let .unableToGetBinarySizeOnDisk(underlyingError):
                return "Failed to get archive size with error: \(underlyingError.localizedDescription)"
            case let .unableToRetrieveAppProject(path):
                return "Failed to get MeasurementApp project from XcodeProj at path: \(path)"
        }
    }
}
