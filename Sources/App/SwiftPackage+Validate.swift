//
//  SwiftPackage+Validate.swift
//  swift-package-info
//
//  Created by Marino Felipe on 30.01.25.
//

import Core

import PackageModel

enum SwiftPackageValidationError: Error {
  case invalidURL
  case failedToLoadPackage
  case noProductFound
}

extension SwiftPackage {
  mutating func validate(
    swiftPackageService: SwiftPackageService = SwiftPackageService(),
    isVerbose: Bool = false,
    console: Console? = nil // only available on CLI
  ) async throws(SwiftPackageValidationError) -> Package {
    let packageResponse: SwiftPackageValidationResult
    do {
      packageResponse = try await swiftPackageService.validate(
        swiftPackage: self,
        verbose: isVerbose
      )
    } catch {
      throw .failedToLoadPackage
    }

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
        throw SwiftPackageValidationError.invalidURL
      }

      switch self.resolution {
      case let .revision(revision):
        await console?.lineBreakAndWrite("Resolved revision: \(revision)")
      case .version:
        switch tagState {
        case .undefined, .invalid:
          await console?.lineBreakAndWrite("Package version was \(tagState.description)")

          if let latestTag {
            await console?.lineBreakAndWrite("Defaulting to latest found semver tag: \(latestTag)")
            self.resolution = .version(latestTag)
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
//      )
      throw .noProductFound
    }

    if packageResponse.isProductValid == false {
      await console?.lineBreakAndWrite("Invalid product: \(self.product)")
      await console?.lineBreakAndWrite("Using first found product instead: \(firstProduct)")

      self.product = firstProduct
    }

    return packageResponse.package
  }
}
