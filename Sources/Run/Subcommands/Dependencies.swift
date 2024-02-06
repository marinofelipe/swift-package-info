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
import Core
import App
import Reports

extension SwiftPackageInfo {
  public struct Dependencies: AsyncParsableCommand {
    public static var configuration = CommandConfiguration(
      abstract: "List dependencies of a Package product.",
      discussion: """
            Show direct and indirect dependencies of a product, listing
            all dependencies that are linked to its binary.
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

      try DependenciesProvider.fetchInformation(
        for: swiftPackage,
        package: packageWrapper, 
        xcconfig: allArguments.xcconfig,
        verbose: allArguments.verbose
      )
      .onSuccess {
        try report.generate(
          for: $0,
          format: allArguments.report
        )
      }
      .onFailure { Console.default.write($0.message) }
    }
  }
}
