//
//  PackageContent.swift
//  
//
//  Created by Marino Felipe on 23.01.21.
//

import struct TSCUtility.Version

public struct PackageContent: Decodable, Equatable {
    public struct Product: Decodable, Equatable {
        public enum Kind: Decodable, Equatable {
            public enum LibraryKind: String, Decodable {
                case dynamic = "automatic"
                case `static`
            }

            case executable
            case library(LibraryKind)

            private enum CodingKeys: String, CodingKey {
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
                let lowerBound: Version
                let upperBound: Version
            }

            let range: [Range]
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
        public struct Dependency: Decodable, Equatable {
            let target: [String?]?
            let product: [String?]?
            let byName: [String?]?
        }

        enum Kind: String, Decodable, Equatable {
            case regular
            case test
        }


        let name: String
        let dependencies: [Dependency]
        let kind: Kind

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
