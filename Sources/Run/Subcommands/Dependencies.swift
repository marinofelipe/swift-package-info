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
import Core
import App
import Reports

extension SwiftPackageInfo {
  public struct Dependencies: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
      abstract: "List dependencies of a Package product.",
      discussion: """
            Show direct and indirect dependencies of a product, listing
            all dependencies that are linked to its binary.
            """,
      version: SwiftPackageInfo.configuration.version
    )

    @OptionGroup var allArguments: AllArguments

    public init() {}

    @MainActor
    public func run() async throws {
      try runArgumentsValidation(arguments: allArguments)

      var packageDefinition = try makePackageDefinition(from: allArguments)
      packageDefinition.messages.forEach(Console.default.lineBreakAndWrite)

      let validator = SwiftPackageValidator(console: .default)
      let package: PackageWrapper
      do {
        package = try await validator.validate(packageDefinition: &packageDefinition)
      } catch {
        throw CleanExit.make(from: error)
      }

      do {
        let providedInfo = try await DependenciesProvider.dependencies(
          for: packageDefinition,
          resolvedPackage: package,
          xcconfig: allArguments.xcconfig,
          verbose: allArguments.verbose
        )

        let report = Report(packageDefinition: packageDefinition, console: .default)
        try await report.generate(
          for: providedInfo,
          format: allArguments.report
        )
      } catch {
        if let providerError = error as? InfoProviderError {
          Task { @MainActor in
            Console.default.write(providerError.message)
          }
        }
      }
    }
  }
}
