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
import App
import Core
import Foundation
import Reports

extension SwiftPackageInfo {
  public struct FullAnalyzes: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
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
      var packageDefinition = try makePackageDefinition(from: allArguments)
      packageDefinition.messages.forEach {
        let message = $0
        Task { @MainActor in
          Console.default.lineBreakAndWrite(message)
        }
      }

      let validator = await SwiftPackageValidator(console: .default)
      let package = try await validator.validate(packageDefinition: &packageDefinition)

      let finalPackageDefinition = packageDefinition

      // All copies to silence Swift 6 concurrency `sending` warnings
      let xcconfig = allArguments.xcconfig
      let isVerbose = allArguments.verbose
      let providedInfos: [ProvidedInfo] = try await withThrowingTaskGroup(
        of: ProvidedInfo.self,
        returning: [ProvidedInfo].self
      ) { taskGroup in
        SwiftPackageInfo.subcommandsProviders.forEach { subcommandProvider in
          taskGroup.addTask {
            try await subcommandProvider(
              finalPackageDefinition,
              package,
              xcconfig,
              isVerbose
            )
          }
        }

        var providedInfos: [ProvidedInfo] = []
        for try await result in taskGroup {
          providedInfos.append(result)
        }
        return providedInfos
      }

      let report = await Report(packageDefinition: finalPackageDefinition, console: .default)
      try await report.generate(
        for: providedInfos,
        format: allArguments.report
      )
    }
  }
}

extension CommandConfiguration: @retroactive @unchecked Sendable {}


// 1. validates and updates the package input
// 2. calls info provider -> provides info
// 3. calls reporter -> provides report

// Executable
// Needs both validation, provider and reporter

// Library
// Needs (input) -> output
// with validation included, and ideally internally resolved

// Library target
// - has wrapper around providers
// - for that we need the validation to be moved out
// - the validation should be safer - no inout

// Action items
// - Make validation safer and improve executable
// - then build library target
