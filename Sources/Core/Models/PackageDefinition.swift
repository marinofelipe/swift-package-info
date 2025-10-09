//  Copyright (c) 2025 Felipe Marino
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

public import struct Foundation.URL
public import Basics

/// Defines a Swift Package product.
/// The initial input needed to resolve the package graph and provide the required information.
@dynamicMemberLookup
public struct PackageDefinition: Equatable, CustomStringConvertible, Sendable {
  /// The remote repository resolution, either a git tag or revision.
  public nonisolated enum RemoteResolution: Equatable, CustomStringConvertible, Sendable {
    /// Semantic version of the Swift Package. If not valid, the latest semver tag is used
    case version(String)
    /// A single git commit, SHA-1 hash, or branch name
    case revision(String)

    public var description: String {
      switch self {
      case let .revision(revision):
        return "Revision: \(revision)"
      case let .version(tag):
        return "Version: \(tag)"
      }
    }

    var version: String? {
      switch self {
      case .revision: nil
      case let .version(tag): tag
      }
    }

    var revision: String? {
      switch self {
      case let .revision(revision): revision
      case .version: nil
      }
    }
  }

  /// The source reference for the Package repository.
  public nonisolated enum Source: Equatable, Sendable, CustomStringConvertible {
    /// A relative local directory path that contains a `Package.swift`. **Full paths not supported**.
    case local(AbsolutePath)
    /// A valid git repository URL that contains a `Package.swift` and it's resolution method, either the git version or revision.
    case remote(url: URL, resolution: RemoteResolution)

    public var description: String {
      switch self {
      case let .local(path):
        "Local path: \(path)"
      case let .remote(url, resolution):
        """
        Repository URL: \(url)
        \(resolution.description)
        """
      }
    }

    public var remoteResolution: RemoteResolution? {
      switch self {
      case .local: nil
      case let .remote(_, resolution): resolution
      }
    }

    public var url: URL {
      switch self {
      case let .local(path): path.asURL
      case let .remote(remoteURL, _): remoteURL
      }
    }

    public var version: String? {
      switch self {
      case .local: nil
      case let .remote(_, resolution): resolution.version
      }
    }

    public var revision: String? {
      switch self {
      case .local: nil
      case let .remote(_, resolution): resolution.revision
      }
    }
  }

  /// A ``PackageDefinition`` initialization error.
  public enum Error: Swift.Error {
    case invalidURL
  }

  public var source: Source
  public var product: String

  /// Initializes a ``PackageDefinition``
  /// - Parameters:
  ///   - source: The source reference for the Package repository.
  ///   - product: Name of the product to be checked. If not passed in the first available product is used.
  public init(
    source: Source,
    product: String?
  ) throws(PackageDefinition.Error) {
    switch source {
    case let .local(absolutePath):
      let isValidLocalDirectory = try? absolutePath.asURL.isLocalDirectoryContainingPackageDotSwift()
      guard isValidLocalDirectory ?? false else {
        throw Error.invalidURL
      }
    case let .remote(url, _):
      guard url.isValidRemote else {
        throw Error.invalidURL
      }
    }

    self.source = source
    // N.B. Set as `undefined` which is used later on for replacing it for a valid Product
    self.product = product ?? ResourceState.undefined.description
  }

  /// Initializes a ``PackageDefinition`` from CLI arguments
  /// - Parameters:
  ///   - url: Either a valid git repository URL or a relative local directory path that contains a `Package.swift`. For local packages **full paths are discouraged and unsupported**.
  ///   - version: Semantic version of the Swift Package. If not passed and `revision` is not set, the latest semver tag is used.
  ///   - revision: A single git commit, SHA-1 hash, or branch name. Applied when `packageVersion` is not set.
  ///   - product: Name of the product to be checked. If not passed in the first available product is used.
  @_disfavoredOverload
  public init(
    url: URL,
    version: String?,
    revision: String?,
    product: String?
  ) throws(PackageDefinition.Error) {
    let isValidRemoteURL = url.isValidRemote
    let isValidLocalDirectory = (try? url.isLocalDirectoryContainingPackageDotSwift()) ?? false

    guard isValidRemoteURL || isValidLocalDirectory else {
      throw Error.invalidURL
    }

    if isValidLocalDirectory {
      let path: AbsolutePath
      do {
        path = try AbsolutePath(
          validating: url.absoluteString,
          relativeTo: .currentDir
        )
      } catch {
        throw PackageDefinition.Error.invalidURL
      }
      self.source = .local(path)
    } else {
      let resolvedVersion = version ?? ResourceState.undefined.description
      if let revision = revision, resolvedVersion == ResourceState.undefined.description {
        self.source = .remote(url: url, resolution: .revision(revision))
      } else {
        self.source = .remote(url: url, resolution: .version(resolvedVersion))
      }
    }

    // N.B. Set as `undefined` which is used later on for replacing it for a valid Product
    self.product = product ?? ResourceState.undefined.description
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<Source, T>) -> T {
    source[keyPath: keyPath]
  }

  public var description: String {
    """
    \(source.description)
    Product: \(product)
    """
  }
}
