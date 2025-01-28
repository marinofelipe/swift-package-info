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

public struct SwiftPackage: Equatable, CustomStringConvertible, Sendable {
  public enum Resolution: Equatable, CustomStringConvertible, Sendable {
    case version(String)
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

  public init(
    url: URL,
    isLocal: Bool,
    version: String,
    revision: String?,
    product: String
  ) {
    self.url = url
    self.isLocal = isLocal
    self.product = product

    if let revision = revision, version == ResourceState.undefined.description {
      self.resolution = .revision(revision)
    } else {
      self.resolution = .version(version)
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

public extension SwiftPackage {
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
