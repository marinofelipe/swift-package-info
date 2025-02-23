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

import Core
import Foundation

// MARK: - Types

enum BinarySizeProviderError: LocalizedError, Equatable {
  case unableToGenerateArchive(errorMessage: String)
  case unableToCloneEmptyApp(errorMessage: String)
  case unableToGetBinarySizeOnDisk(underlyingError: NSError)
  case unableToRetrieveAppProject(atPath: String)
  case unexpectedError(underlyingError: NSError, isVerbose: Bool)

  var errorDescription: String? {
    let step: String
    let message: String
    switch self {
    case let .unableToGenerateArchive(errorMessage):
      step = "Archiving"
      message = errorMessage
    case let .unableToCloneEmptyApp(errorMessage):
      step = "Cloning empty app"
      message = errorMessage
    case let .unableToGetBinarySizeOnDisk(underlyingError):
      step = "Reading binary size"
      message = "Failed to read binary size from archive. Details: \(underlyingError.localizedDescription)"
    case let .unableToRetrieveAppProject(path):
      step = "Read measurement app project"
      message = "Failed to get MeasurementApp project from XcodeProj at path: \(path)"
    case let .unexpectedError(underlyingError, isVerboseOn):
      step = "Undefined"
      message = """
                Unexpected failure. \(underlyingError.description).
                \(isVerboseOn ? "" : "Please run with --verbose enabled for more details.")
                """
    }

    return """
        Failed to measure binary size
        Step: \(step)
        Error: \(message)
        """
  }
}

struct BinarySizeInformation: Equatable, Encodable, CustomConsoleMessagesConvertible {
  private let amount: Int
  private let formatted: String

  var messages: [ConsoleMessage] { buildConsoleMessages() }

  init(binarySize: SizeOnDisk) {
    self.amount = binarySize.amount
    self.formatted = binarySize.formatted
  }

  private enum CodingKeys: String, CodingKey {
    case amount
    case formatted
  }

  private func buildConsoleMessages() -> [ConsoleMessage] {
    [
      .init(
        text: "Binary size increases by ",
        color: .noColor,
        isBold: false,
        hasLineBreakAfter: false
      ),
      .init(
        text: formatted,
        color: .yellow,
        isBold: true,
        hasLineBreakAfter: false
      )
    ]
  }
}

// MARK: - Provider

public struct BinarySizeProvider {
  @Sendable
  public static func fetchInformation(
    for swiftPackage: SwiftPackage,
    package: PackageWrapper,
    xcconfig: URL?,
    verbose: Bool
  ) async throws -> ProvidedInfo { // throws(InfoProviderError): typed throws only supported from macOS 15 runtime
    let sizeMeasurer = await defaultSizeMeasurer(xcconfig, verbose)
    var binarySize: SizeOnDisk = .zero

    let isProductDynamicLibrary = package.products
      .first{ $0.name == swiftPackage.product }?
      .isDynamicLibrary ?? false

    do {
      binarySize = try await sizeMeasurer(
        swiftPackage,
        isProductDynamicLibrary
      )
    } catch let error as LocalizedError {
      throw InfoProviderError(localizedError: error)
    } catch {
      throw InfoProviderError(
        localizedError: BinarySizeProviderError.unexpectedError(
          underlyingError: error as NSError,
          isVerbose: verbose
        )
      )
    }

    return ProvidedInfo(
      providerName: "Binary Size",
      providerKind: .binarySize,
      information: BinarySizeInformation(
        binarySize: binarySize
      )
    )
  }
}

// MARK: - Library

extension BinarySizeProvider {
  public static func binarySize(
    for swiftPackage: SwiftPackage,
    xcconfig: URL? = nil
  ) async throws -> ProvidedInfo {
    var finalSwiftPackage = swiftPackage

    // FIXME: Reuse validate method from Run package
    let swiftPackageService = SwiftPackageService()
    let packageResponse = try await swiftPackageService.validate(
      swiftPackage: swiftPackage,
      verbose: false
    )

    switch packageResponse.sourceInformation {
    case let .remote(isRepositoryValid, tagState, latestTag):
      guard isRepositoryValid else {
//        throw CleanExit.message(
//          """
//          Error: Invalid argument '--url <url>'
//          Usage: The URL must be a valid git repository URL that contains
//          a `Package.swift`, e.g `https://github.com/Alamofire/Alamofire`
//          """
//        )
        // FIXME: Proper error, reuse from Run target
        throw BinarySizeProviderError.unableToCloneEmptyApp(errorMessage: "")
      }

      switch swiftPackage.resolution {
      case let .revision(revision):
        // FIXME: Enable console only via CLI
        await Console.default.lineBreakAndWrite("Resolved revision: \(revision)")
      case .version:
        switch tagState {
        case .undefined, .invalid:
          await Console.default.lineBreakAndWrite("Package version was \(tagState.description)")

          if let latestTag {
            await Console.default.lineBreakAndWrite("Defaulting to latest found semver tag: \(latestTag)")
            finalSwiftPackage.resolution = .version(latestTag)
          }
        case .valid:
          break
        }
      }
    case .local:
      break
    }

    guard let firstProduct = packageResponse.availableProducts.first else {
//      throw CleanExit.message(
//        "Error: \(swiftPackage.url) doesn't contain any product declared on Package.swift"
      // FIXME: Proper error, reuse from Run target
      throw BinarySizeProviderError.unableToCloneEmptyApp(errorMessage: "")
    }

    if packageResponse.isProductValid == false {
      // FIXME: Enable console only via CLI
      await Console.default.lineBreakAndWrite("Invalid product: \(finalSwiftPackage.product)")
      await Console.default.lineBreakAndWrite("Using first found product instead: \(firstProduct)")

      finalSwiftPackage.product = firstProduct
    }

    let package = packageResponse.package
    let packageWrapper = PackageWrapper(from: package)

    return try await fetchInformation(
      for: swiftPackage,
      package: packageWrapper,
      xcconfig: xcconfig,
      verbose: false
    )
  }
}

#if DEBUG
// debug only
nonisolated(unsafe) var defaultSizeMeasurer: (URL?, Bool) async -> SizeMeasuring = { xcconfig, verbose in
  await SizeMeasurer(verbose: verbose, xcconfig: xcconfig).binarySize
}
#else
let defaultSizeMeasurer: (URL?, Bool) async -> SizeMeasuring = { xcconfig, verbose in
  await SizeMeasurer(verbose: verbose, xcconfig: xcconfig).binarySize
}
#endif
