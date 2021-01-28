//
//  PackageContent.swift
//  
//
//  Created by Marino Felipe on 23.01.21.
//

import Foundation
import struct TSCUtility.Version

public enum PackageContentError: LocalizedError {
    case failedToDecodeTargetDependencyType

    public var errorDescription: String? {
        switch self {
            case .failedToDecodeTargetDependencyType:
                return "Failed to decode target dependency type when evaluating Package.swift content"
        }
    }
}

public struct PackageContent: Decodable, Equatable {
    public struct Product: Decodable, Equatable {
        public enum Kind: Equatable {
            public enum LibraryKind: String, Decodable {
                case dynamic
                case `static`
                case automatic
            }

            case executable
            case library(LibraryKind)
        }

        public let name: String
        public let targets: [String]
        public let kind: Kind

        private enum CodingKeys: String, CodingKey {
            case name
            case targets
            case kind = "type"
        }
    }

    public struct Dependency: Decodable, Equatable {
        public struct Requirement: Decodable, Equatable {
            public struct Range: Decodable, Equatable {
                public let lowerBound: Version
                public let upperBound: Version
            }

            public let range: [Range]
        }

        public let name: String
        public let urlString: String
        public let requirement: Requirement

        private enum CodingKeys: String, CodingKey {
            case name
            case urlString = "url"
            case requirement
        }
    }

    public struct Platform: Decodable, Equatable {
        public let platformName: String
        public let version: String
    }

    public struct Target: Decodable, Equatable {
        public enum Dependency: Equatable {
            case target([String])
            case product([String])
            case byName([String])
        }

        public enum Kind: String, Decodable, Equatable {
            case regular
            case test
        }

        public let name: String
        public let dependencies: [Dependency]
        public let kind: Kind

        private enum CodingKeys: String, CodingKey {
            case name
            case dependencies
            case kind = "type"
        }
    }

    public let name: String
    public let platforms: [Platform]
    public let products: [Product]
    public let dependencies: [Dependency]
    public let targets: [Target]
    public let swiftLanguageVersions: [String]?
}

extension PackageContent.Product.Kind: Decodable {
    enum CodingKeys: String, CodingKey {
        case executable
        case library
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let libraryKind = try container.decodeIfPresent([LibraryKind].self, forKey: .library)?.first else {
            self = .executable
            return
        }
        
        self = .library(libraryKind)
    }
}

extension PackageContent.Target.Dependency: Decodable {
    enum CodingKeys: String, CodingKey {
        case target
        case product
        case byName
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let targets = try container.decodeIfPresent([String?].self, forKey: .target)?.compactMap({ $0 }) {
            self = .target(targets)
        } else if let products = try container.decodeIfPresent([String?].self, forKey: .product)?.compactMap({ $0 }) {
            self = .product(products)
        } else if let dependenciesNames = try container.decodeIfPresent([String?].self, forKey: .byName)?.compactMap({ $0 }) {
            self = .byName(dependenciesNames)
        }  else {
            throw PackageContentError.failedToDecodeTargetDependencyType
        }
    }
}

public extension PackageContent.Target.Dependency {
    var target: String? {
        guard case let .target(targets) = self else { return nil }
        return targets.first
    }

    var product: String? {
        guard case let .product(products) = self else { return nil }
        return products[safeIndex: 1]
    }

    var byName: String? {
        guard case let .byName(names) = self else { return nil }
        return names.first
    }
}
