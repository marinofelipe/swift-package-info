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

import struct Foundation.URL

/// Defines a Swift Package product.
/// The initial input needed to resolve the package graph and provide the required information.
public struct PackageDefinition: Equatable, CustomStringConvertible, Sendable {
  public enum Resolution: Equatable, CustomStringConvertible, Sendable {
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
  }

  public let url: URL
  public let isLocal: Bool
  public var resolution: Resolution
  public var product: String

  public enum Error: Swift.Error {
    case invalidURL
  }

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

    self.url = url
    self.isLocal = isValidLocalDirectory
    self.product = product ?? ResourceState.undefined.description // TODO: Why use undefined?

    let resolvedVersion = version ?? ResourceState.undefined.description
    if let revision = revision, resolvedVersion == ResourceState.undefined.description {
      self.resolution = .revision(revision)
    } else {
      self.resolution = .version(resolvedVersion)
    }
  }

  public var description: String {
    """
    \(isLocal ? "Local path" : "Repository URL"): \(url)
    \(resolution.description)
    Product: \(product)
    """
  }
}

public extension PackageDefinition {
  var accountName: String {
    guard isLocal == false else { return "" }

    return url
      .pathComponents[safeIndex: url.pathComponents.count - 2] ?? ""
  }

  var repositoryName: String {
    guard isLocal == false else { return "" }

    return (url.pathComponents.last ?? "")
      .replacingOccurrences(of: ".git", with: "")
  }
}
