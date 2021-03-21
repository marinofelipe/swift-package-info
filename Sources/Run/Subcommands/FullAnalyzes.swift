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
            abstract: "All available information about a Swift Package product.",
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

            let packageContent = try validate(
                swiftPackage: &swiftPackage,
                verbose: allArguments.verbose
            )

            let report = Report(swiftPackage: swiftPackage)

            // Providers have a synchronous API and are run in sequence. Each of them, even when performing async tasks, have to fulfill a sync API.
            // For current setup it works as wanted, since the only heavy provider is binary size, that executes xcodebuild commands that are logged into the console
            // when verbose flag is passed in. All other providers have sync logic that consumes PackageContent (Package.swift) decoded and provide specific
            // information over it.
            // Adding providers with asynchronous tasks should be avoided, and in case of adding any appears, things can be re-evaluated to run providers concurrently.
            var providedInfos: [ProvidedInfo] = []
            SwiftPackageInfo.subcommandsProviders.forEach { subcommandProvider in
                subcommandProvider(
                    swiftPackage,
                    packageContent,
                    allArguments.verbose
                )
                .onSuccess { providedInfos.append($0) }
                .onFailure { Console.default.write($0.message) }
            }
            try report.generate(for: providedInfos, format: .jsonDump) // FIXME: Pass format from user arguments
        }
    }
}
