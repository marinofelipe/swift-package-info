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

import ArgumentParser
import struct Foundation.URL
import Core
import App
import Reports

import PackageModel

// MARK: - Main parsable command

@main
public struct SwiftPackageInfo: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    abstract: "A tool for analyzing Swift Packages",
    discussion: """
    Provides valuable information about a given Swift Package,
    that can be used in your favor when deciding whether to
    adopt or not a Swift Package as a dependency on your app.
    """,
    version: "1.6.0",
    subcommands: [
      BinarySize.self,
      Platforms.self,
      Dependencies.self,
      FullAnalyzes.self
    ],
    defaultSubcommand: FullAnalyzes.self
  )

  static let subcommandsProviders: [InfoProvider] = [
    BinarySizeProvider.binarySize(for:resolvedPackage:xcconfig:verbose:),
    PlatformsProvider.platforms(for:resolvedPackage:xcconfig:verbose:),
    DependenciesProvider.dependencies(for:resolvedPackage:xcconfig:verbose:)
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
    Either a valid git repository or the relative or absolute path to a local directory that contains a `Package.swift`.
    """
  )
  var url: URL

  @Option(
    name: [
      .long,
      .customShort("v")
    ],
    help: "Semantic version of the Swift Package. If not passed and `revision` is not set, the latest semver tag is used"
  )
  var packageVersion: String?

  @Option(
    name: [
      .long,
      .customShort("r")
    ],
    help: "A single git commit, SHA-1 hash, or branch name. Applied when `packageVersion` is not set"
  )
  var revision: String?

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

  @Option(
    name: [
      .customLong("xcconfig"),
    ],
    help: """
        A valid relative local directory path that point to a file of type `.xcconfig`
        """
  )
  var xcconfig: URL? = nil

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
    let isValidLocalCustomFile = arguments.xcconfig?.isLocalXCConfigFileValid()

    guard isValidRemoteURL || isValidLocalDirectory == true else {
      throw CleanExit.message(
        """
        Error: Invalid argument '--url <url>'
        Usage: The URL must be either:
        - A valid git repository URL that contains a `Package.swift`, e.g `https://github.com/Alamofire/Alamofire`; or
        - A relative or absolute path to a local directory that has a `Package.swift`, e.g. `../other-dir/my-project`
        """
      )
    }

    if isValidLocalCustomFile == false {
      throw CleanExit.message(
        """
        Error: Invalid argument '--xcconfig <url>'
        Usage: The URL must be a relative local file path that has point to a `.xcconfig` file, e.g. `../other-dir/CustomConfiguration.xcconfig`
        """
      )
    }
  }

  func makePackageDefinition(from arguments: AllArguments) throws -> PackageDefinition {
    try PackageDefinition(
      url: arguments.url,
      version: arguments.packageVersion,
      revision: arguments.revision,
      product: arguments.product
    )
  }
}

extension CleanExit {
  static func make(from validationError: SwiftPackageValidationError) -> Self {
    switch validationError {
    case .invalidURL:
      CleanExit.message(
        """
        Error: Invalid argument '--url <url>'
        Usage: The URL must be a valid git repository URL that contains
        a `Package.swift`, e.g `https://github.com/Alamofire/Alamofire`
        """
      )
    case .failedToLoadPackage:
      CleanExit.message("<no idea>")
    case let .noProductFound(packageURL):
      CleanExit.message(
        "Error: \(packageURL) doesn't contain any product declared on Package.swift"
      )
    }
  }
}
