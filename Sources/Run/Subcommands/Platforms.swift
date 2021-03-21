//
//  Platforms.swift
//
//
//  Created by Marino Felipe on 03.01.21.
//

import ArgumentParser
import Core
import App
import Reports

extension SwiftPackageInfo {
    public struct Platforms: ParsableCommand {
        public static var configuration = CommandConfiguration(
            abstract: "Shows platforms supported b a Package product.",
            discussion: """
            Informs supported platforms by a given Package.swift and its products,
            e.g 'iOS with 9.0 minimum deployment target'.
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

            try PlatformsProvider.fetchInformation(
                for: swiftPackage,
                packageContent: packageContent,
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
