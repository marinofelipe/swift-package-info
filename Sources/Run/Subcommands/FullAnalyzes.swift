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
import App
import Core
import Foundation
import Reports

extension SwiftPackageInfo {
  public struct FullAnalyzes: AsyncParsableCommand {
    public static var configuration = CommandConfiguration(
      abstract: "All available information about a Swift Package product.",
      discussion: """
            Runs all available providers (each one available via a subcommand, e.g. BinarySize),
            and generates a full report of a given Swift Package product for a specific version.
            """,
      version: SwiftPackageInfo.configuration.version
    )

    @OptionGroup var allArguments: AllArguments

    public init() {}

    public func run() async throws {
      try runArgumentsValidation(arguments: allArguments)
      var swiftPackage = makeSwiftPackage(from: allArguments)
      swiftPackage.messages.forEach(Console.default.lineBreakAndWrite)

      let package = try await validate(
        swiftPackage: &swiftPackage,
        verbose: allArguments.verbose
      )

      let report = Report(swiftPackage: swiftPackage)

      let packageWrapper = PackageWrapper(from: package)

      // Providers have a synchronous API and are run in sequence. Each of them, even when performing async tasks, have to fulfill a sync API.
      // For current setup it works as wanted, since the only heavy provider is binary size, that executes xcodebuild commands that are logged into the console
      // when verbose flag is passed in. All other providers have sync logic that consumes PackageContent (Package.swift) decoded and provide specific
      // information over it.
      // Adding providers with asynchronous tasks should be avoided, and in case of adding any appears, things can be re-evaluated to run providers concurrently.
      var providedInfos: [ProvidedInfo] = []
      SwiftPackageInfo.subcommandsProviders.forEach { subcommandProvider in
        subcommandProvider(
          swiftPackage,
          packageWrapper,
          allArguments.xcconfig,
          allArguments.verbose
        )
        .onSuccess { providedInfos.append($0) }
        .onFailure { Console.default.write($0.message) }
      }
      try report.generate(
        for: providedInfos,
        format: allArguments.report
      )
    }
  }
}
