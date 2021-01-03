//
//  FullAnalyzes.swift
//  
//
//  Created by Marino Felipe on 03.01.21.
//

import ArgumentParser
import Core
import Reports

extension SwiftPackageInfo {
    public struct FullAnalyzes: ParsableCommand {
        public static var configuration = CommandConfiguration(
            abstract: "Get all provided information about a Swift Package",
            discussion: """
            Runs all available providers (each one available via a subcommand, e.g. BinarySize),
            and generates a full report of a given Swift Package product for a specific version.
            """,
            version: "1.0"
        )

        @OptionGroup var allArguments: AllArguments

        public init() {}

        public func run() throws {
            try runArgumentsValidation(arguments: allArguments)
            let swiftPackage = makeSwiftPackage(from: allArguments)
            swiftPackage.messages.forEach(Console.default.lineBreakAndWrite)

            // TODO: Check Package.swift to see if repository URL, version and product are valid, before moving on.

            let report = Report(swiftPackage: swiftPackage)

            // For the moment being all providers are run in a sequence, and each of them, even if performing and async task, have a sync API,
            // since the terminal is updated with logs of the current operation.
            // The concept of running providers, or at least some, in parallel, is not supported, and must be carefully investigated.
            var providedInfos: [ProvidedInfo] = []
            SwiftPackageInfo.subcommandsProviders.forEach { subcommandProvider in
                subcommandProvider(
                    swiftPackage,
                    allArguments.verbose
                ) { result in
                    result
                        .onSuccess { providedInfos.append($0) }
                        .onFailure { Console.default.write($0.message) }
                }
            }
            report.generate(for: providedInfos)
        }
    }
}
