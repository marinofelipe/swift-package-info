//
//  SwiftPackageValidator.swift
//  swift-package-info
//
//  Created by Marino Felipe on 16.02.25.
//

public import Foundation
internal import PackageModel

public import Core

public enum SwiftPackageValidationError: Error, Equatable {
  case invalidURL
  case failedToLoadPackage
  case noProductFound(packageURL: URL)
}

public protocol SwiftPackageValidating {
  func validate(
    packageDefinition: inout PackageDefinition,
    isVerbose: Bool
  ) async throws(SwiftPackageValidationError) -> PackageWrapper
}

/// Uses the `SPM` library to load the package from its local or remote source, and then validates and adjusts
/// its properties.
///
/// Depending on the result, it can mutate the ``SwiftPackage`` with:
/// - a valid first `Product`, if no product is passed or invalid
/// - the latest `tag` as `resolution`, in case the passed tag is invalid
public struct SwiftPackageValidator: SwiftPackageValidating {
  private let swiftPackageService: SwiftPackageService
  private let console: Console?

  public init(console: Console? = nil) {
    self.init(
      swiftPackageService: .init(),
      console: console
    )
  }

  init(
    swiftPackageService: SwiftPackageService = .init(),
    console: Console? = nil
  ) {
    self.swiftPackageService = swiftPackageService
    self.console = console
  }

  public func validate(
    packageDefinition: inout PackageDefinition,
    isVerbose: Bool = false
  ) async throws(SwiftPackageValidationError) -> PackageWrapper {
    let packageResponse: SwiftPackageValidationResult
    do {
      packageResponse = try await swiftPackageService.validate(
        swiftPackage: packageDefinition,
        verbose: isVerbose
      )
    } catch {
      throw .failedToLoadPackage
    }

    switch packageResponse.sourceInformation {
    case let .remote(isRepositoryValid, tagState, latestTag):
      guard isRepositoryValid else {
        throw SwiftPackageValidationError.invalidURL
      }

      switch packageDefinition.source.remoteResolution {
      case let .revision(revision):
        await console?.lineBreakAndWrite("Resolved revision: \(revision)")
      case .version:
        switch tagState {
        case .undefined, .invalid:
          await console?.lineBreakAndWrite("Package version was \(tagState.description)")

          if let latestTag {
            await console?.lineBreakAndWrite("Defaulting to latest found semver tag: \(latestTag)")
            packageDefinition.source = .remote(
              url: packageDefinition.url,
              resolution: .version(latestTag)
            )
          }
        case .valid:
          break
        }
      case .none:
        break
      }
    case .local:
      break
    }

    guard let firstProduct = packageResponse.availableProducts.first else {
      throw .noProductFound(packageURL: packageDefinition.url)
    }

    if packageResponse.isProductValid == false {
      await console?.lineBreakAndWrite("Invalid product: \(packageDefinition.product)")
      await console?.lineBreakAndWrite("Using first found product instead: \(packageDefinition)")

      packageDefinition.product = firstProduct
    }

    return packageResponse.package
  }
}
