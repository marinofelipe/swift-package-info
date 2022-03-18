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

import Foundation
import struct TSCUtility.Version

public enum PackageContentError: LocalizedError {
    case failedToDecodeTargetDependencyType
    case failedToDecodeDependenciesFromSwift5Dot5Toolchain
    case failedToDecodeDependenciesFromSwift5Dot6Toolchain

    public var errorDescription: String? {
        switch self {
            case .failedToDecodeTargetDependencyType:
                return "Failed to decode target dependency type when evaluating Package.swift content"
        case .failedToDecodeDependenciesFromSwift5Dot5Toolchain:
            return "Failed to decode package dependencies from Package.swift generated using the Swift 5.5 toolchain"
        case .failedToDecodeDependenciesFromSwift5Dot6Toolchain:
            return "Failed to decode package dependencies from Package.swift generated using the Swift 5.6 toolchain"
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

    public struct Dependency: Equatable, Hashable {
        public struct Requirement: Equatable, Hashable {
            public struct Range: Decodable, Equatable, Hashable {
                public let lowerBound: Version
                public let upperBound: Version
            }

            public let range: [Range]
            public let revision: [String]
            public let branch: [String]
        }
        public struct Location: Decodable, Equatable, Hashable {
            public let remote: [String]
        }

        public let name: String
        public let urlString: String
        public let requirement: Requirement?
    }

    public struct Platform: Decodable, Equatable {
        public let platformName: String
        public let version: String
    }

    public struct Target: Decodable, Equatable {
        public enum Dependency: Equatable {
            public enum Content: Equatable {
                public struct Platforms: Decodable, Equatable {
                    let platformNames: [String]
                }

                case name(String)
                case platforms(Platforms)
            }

            case target([Content])
            case product([Content])
            case byName([Content])
        }

        public enum Kind: String, Decodable, Equatable {
            case binary
            case regular
            case test
            case system
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

        if let targets = try container.decodeIfPresent([Content?].self, forKey: .target)?.compactMap({ $0 }) {
            self = .target(targets)
        } else if let products = try container.decodeIfPresent([Content?].self, forKey: .product)?.compactMap({ $0 }) {
            self = .product(products)
        } else if let dependenciesNames = try container.decodeIfPresent([Content?].self, forKey: .byName)?.compactMap({ $0 }) {
            self = .byName(dependenciesNames)
        } else {
            throw PackageContentError.failedToDecodeTargetDependencyType
        }
    }
}

extension PackageContent.Target.Dependency.Content: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        guard let name = try? container.decode(String?.self) else {
            let platforms = try container.decode(Platforms.self)
            self = .platforms(platforms)
            return
        }

        self = .name(name)
    }
}

public extension PackageContent.Target.Dependency.Content {
    var name: String? {
        guard case let .name(name) = self else { return nil }
        return name
    }
}

public extension PackageContent.Target.Dependency {
    var target: String? {
        guard case let .target(targets) = self else { return nil }
        return targets.first(where: { $0.name != nil })?.name
    }

    var product: String? {
        guard case let .product(products) = self else { return nil }
        return products[safeIndex: 1]?.name
    }

    var byName: String? {
        guard case let .byName(names) = self else { return nil }
        return names.last?.name
    }
}

public extension PackageContent.Product {
    var isDynamicLibrary: Bool {
        guard case let .library(libraryKind) = self.kind else { return false }
        return libraryKind == .dynamic
    }
}

extension PackageContent.Dependency.Requirement: Decodable {
    enum CodingKeys: String, CodingKey {
        case range
        case revision
        case branch
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let range = try container.decodeIfPresent([Range].self, forKey: .range)
        self.range = range ?? []

        let revision = try container.decodeIfPresent([String].self, forKey: .revision)
        self.revision = revision ?? []

        let branch = try container.decodeIfPresent([String].self, forKey: .branch)
        self.branch = branch ?? []
    }
}

extension PackageContent.Dependency: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case identity
        case urlString = "url"
        case location
        case requirement
        // custom inner object present when generated from Swift 5.5
        case scm
        // custom inner object and properties present when generated from Swift 5.6
        case sourceControl
        case path
        case fileSystem
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.scm) {
            let scmInnerDependencies = try container.decode(
                [PackageContent.Dependency].self,
                forKey: .scm
            )
            guard let firstSCMInnerDependency = scmInnerDependencies.first else {
                throw PackageContentError.failedToDecodeDependenciesFromSwift5Dot5Toolchain
            }

            self = firstSCMInnerDependency
        } else if container.contains(.sourceControl) {
            let sourceControlInnerDependencies = try container.decode(
                [PackageContent.Dependency].self,
                forKey: .sourceControl
            )
            guard let firstSourceControlInnerDependency = sourceControlInnerDependencies.first else {
                throw PackageContentError.failedToDecodeDependenciesFromSwift5Dot6Toolchain
            }

            self = firstSourceControlInnerDependency
        } else if container.contains(.fileSystem) {
            let fileSystemInnerDependencies = try container.decode(
                [PackageContent.Dependency].self,
                forKey: .fileSystem
            )
            guard let firsFileSystemInnerDependency = fileSystemInnerDependencies.first else {
                throw PackageContentError.failedToDecodeDependenciesFromSwift5Dot6Toolchain
            }

            self = firsFileSystemInnerDependency
        } else {
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            ?? container.decode(String.self, forKey: .identity)

            if
                let location = try? container.decode(Location.self, forKey: .location),
                let remote = location.remote.first
            {
                self.urlString = remote
            } else {
                self.urlString = try container.decodeIfPresent(String.self, forKey: .urlString)
                ?? container.decodeIfPresent(String.self, forKey: .path)
                ?? container.decode(String.self, forKey: .location)
            }

            self.requirement = try container.decodeIfPresent(Requirement.self, forKey: .requirement)
        }
    }
}
