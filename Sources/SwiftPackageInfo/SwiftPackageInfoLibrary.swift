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

internal import App
public import Core
public import Foundation

public enum BinarySize {}

public extension BinarySize {
  protocol Providing {
    func getBinarySize(
      for packageDefinition: PackageDefinition,
      xcConfig: URL?
    ) async throws -> Result
  }
}

public extension BinarySize {
  /// A type that provides the binary size of a given Swift Package Product.
  final class Provider: Providing {
    private let validator: SwiftPackageValidating

    public convenience init() {
      self.init(validator: SwiftPackageValidator())
    }

    init(validator: SwiftPackageValidating = SwiftPackageValidator()) {
      self.validator = validator
    }

    public func getBinarySize(
      for packageDefinition: PackageDefinition,
      xcConfig: URL? //// A valid relative local directory path that point to a file of type `.xcconfig`
    ) async throws(BinarySize.Error) -> Result {
      if
        let xcConfig = xcConfig,
        !xcConfig.isLocalXCConfigFileValid()
      {
        throw Error.invalidXcConfigFile(xcConfig)
      }

      var finalPackageDefinition = packageDefinition

      let package: PackageWrapper
      do {
        package = try await validator.validate(
          packageDefinition: &finalPackageDefinition,
          isVerbose: false
        )
      } catch {
        throw BinarySize.Error.invalidPackageDefinition(
          ValidationError.make(from: error)
        )
      }

      let result: App.BinarySizeProvider.Result
      do {
        result = try await App.BinarySizeProvider.binarySize(
          for: packageDefinition,
          resolvedPackage: package,
          xcConfig: xcConfig
        )
      } catch {
        throw BinarySize.Error.failedToProvideInfo(error)
      }

      return Result(amount: result.amount, formatted: result.formatted)
    }
  }
}

extension BinarySize {
  public struct Result: Sendable {
    let amount: Int
    let formatted: String
  }

  public enum Error: Swift.Error, Sendable, Equatable {
    case invalidPackageDefinition(ValidationError)
    case invalidXcConfigFile(URL)
    case failedToProvideInfo(InfoProviderError)
  }

  // Allows for `App` to be internally imported
  public enum ValidationError: Swift.Error, Equatable, Sendable {
    case invalidURL
    case failedToLoadPackage
    case noProductFound(packageURL: URL)

    static func make(from error: SwiftPackageValidationError) -> Self {
      switch error {
      case .invalidURL:
        .invalidURL
      case .failedToLoadPackage:
        .failedToLoadPackage
      case let .noProductFound(packageURL):
        .noProductFound(packageURL: packageURL)
      }
    }
  }
}
