//
//  Dependencies.swift
//
//
//  Created by Marino Felipe on 03.01.21.
//

import ArgumentParser
import Core
import App
import Reports

extension SwiftPackageInfo {
    public struct Dependencies: ParsableCommand {
        public static var configuration = CommandConfiguration(
            abstract: "List dependencies of a Package product.",
            discussion: """
            Show direct and indirect dependencies of a product, listing
            all dependencies that are linked to its binary.
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

            DependenciesProvider.fetchInformation(
                for: swiftPackage,
                packageContent: packageContent,
                verbose: allArguments.verbose
            )
            .onSuccess(report.generate(for:))
            .onFailure { Console.default.write($0.message) }
        }
    }
}
