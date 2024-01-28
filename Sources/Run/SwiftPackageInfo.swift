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

import ArgumentParser
import struct Foundation.URL
import Core
import App
import Reports

import PackageModel

// MARK: - Main parsable command

@main
public struct SwiftPackageInfo: AsyncParsableCommand {
  public static var configuration = CommandConfiguration(
    abstract: "A tool for analyzing Swift Packages",
    discussion: """
        Provides valuable information about a given Swift Package,
        that can be used in your favor when deciding whether to
        adopt or not a Swift Package as a dependency on your app.
        """,
    version: "1.4.0",
    subcommands: [
      BinarySize.self,
      Platforms.self,
      Dependencies.self,
      FullAnalyzes.self
    ],
    defaultSubcommand: FullAnalyzes.self
  )

  static var subcommandsProviders: [InfoProvider] = [
    BinarySizeProvider.fetchInformation(for:package:verbose:),
    PlatformsProvider.fetchInformation(for:package:verbose:),
    DependenciesProvider.fetchInformation(for:package:verbose:)
  ]

  public init() {}
}

// MARK: - Available arguments

struct AllArguments: ParsableArguments {
  @Option(
    name: [
      .long,
      .customLong("for"),
      .customLong("package"),
      .customLong("repo-url"),
      .customLong("path"),
      .customLong("local-path"),
    ],
    help: """
        Either a valid git repository URL or a relative local directory path that contains a `Package.swift`
        - Note: For local packages full paths are discouraged and unsupported.
        """
  )
  var url: URL

  @Option(
    name: [
      .long,
      .customShort("v")
    ],
    help: "Semantic version of the Swift Package. If not passed in the latest release is used"
  )
  var packageVersion: String?

  @Option(
    name: [
      .long,
      .customLong("product-named"),
      .customLong("product-name")
    ],
    help: "Name of the product to be checked. If not passed in the first available product is used"
  )
  var product: String?

  @Option(
    name: [
      .long,
      .customLong("report-format"),
      .customLong("output"),
      .customLong("output-format")
    ],
    help: """
        Define the report output format/strategy. Supported values are:
        - \(
            ReportFormat.allCases.map(\.rawValue)
                .joined(separator: "\n- ")
        )

        """
  )
  var report: ReportFormat = .consoleMessage

  @Flag(
    name: .long,
    help: "Increase verbosity of informational output"
  )
  var verbose = false
}

// MARK: - Common ParsableCommand extension

extension ParsableCommand {
  func runArgumentsValidation(arguments: AllArguments) throws {
    guard CommandLine.argc > 0 else { throw CleanExit.helpRequest() }

    let isValidRemoteURL = arguments.url.isValidRemote
    let isValidLocalDirectory = try? arguments.url.isLocalDirectoryContainingPackageDotSwift()

    guard arguments.url.absoluteString.first != "/" else {
      throw CleanExit.message(
                """
                Error: Invalid argument '--url <url>'
                Usage: Absolute paths aren't supported! Please pass a relative path to your local package.
                """
      )
    }

    guard isValidRemoteURL || isValidLocalDirectory == true else {
      throw CleanExit.message(
                """
                Error: Invalid argument '--url <url>'
                Usage: The URL must be either:
                - A valid git repository URL that contains a `Package.swift`, e.g `https://github.com/Alamofire/Alamofire`; or
                - A relative local directory path that has a `Package.swift`, e.g. `../other-dir/my-project`
                """
      )
    }
  }

  func makeSwiftPackage(from arguments: AllArguments) -> SwiftPackage {
    .init(
      url: arguments.url,
      isLocal: arguments.url.isValidRemote ? false : true,
      version: arguments.packageVersion ?? ResourceState.undefined.description,
      product: arguments.product ?? ResourceState.undefined.description
    )
  }

  func validate(
    swiftPackage: inout SwiftPackage,
    verbose: Bool
  ) async throws -> Package {
    let swiftPackageService = SwiftPackageService()
    let packageResponse = try await swiftPackageService.validate(
      swiftPackage: swiftPackage,
      verbose: verbose
    )

    switch packageResponse.sourceInformation {
    case let .remote(isRepositoryValid, tagState, latestTag):
      guard isRepositoryValid else {
        throw CleanExit.message(
          """
          Error: Invalid argument '--url <url>'
          Usage: The URL must be a valid git repository URL that contains
          a `Package.swift`, e.g `https://github.com/Alamofire/Alamofire`
          """
        )
      }

      switch tagState {
      case .undefined, .invalid:
        Console.default.lineBreakAndWrite("Package version was \(tagState.description)")

        if let latestTag {
          Console.default.lineBreakAndWrite("Defaulting to latest found tag: \(latestTag)")
          swiftPackage.version = latestTag
        }
      case .valid:
        break
      }
    case .local:
      break
    }

    guard let firstProduct = packageResponse.availableProducts.first else {
      throw CleanExit.message(
        "Error: \(swiftPackage.url) doesn't contain any product declared on Package.swift"
      )
    }

    if packageResponse.isProductValid == false {
      Console.default.lineBreakAndWrite("Invalid product: \(swiftPackage.product)")
      Console.default.lineBreakAndWrite("Using first found product instead: \(firstProduct)")

      swiftPackage.product = firstProduct
    }

    return packageResponse.package
  }
}
