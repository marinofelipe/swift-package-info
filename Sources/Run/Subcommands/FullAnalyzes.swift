//
//  FullAnalyzes.swift
//  
//
//  SwiftPackageInfo.swift
//
//
//  Created by Marino Felipe on 03.01.21.
//

import ArgumentParser
import App
import Core
import Foundation
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
            var swiftPackage = makeSwiftPackage(from: allArguments)
            swiftPackage.messages.forEach(Console.default.lineBreakAndWrite)

            try validate(swiftPackage: &swiftPackage, arguments: allArguments)

            let report = Report(swiftPackage: swiftPackage)

            // Providers have a synchronous API and are run in sequence. Each of them, even when performing async tasks, have to fulfill a sync API,
            // since generally the terminal is updated with logs of the current operation.
            var providedInfos: [ProvidedInfo] = []
            SwiftPackageInfo.subcommandsProviders.forEach { subcommandProvider in
                subcommandProvider(
                    swiftPackage,
                    allArguments.verbose
                )
                .onSuccess { providedInfos.append($0) }
                .onFailure { Console.default.write($0.message) }
            }
            report.generate(for: providedInfos)
        }
    }
}
