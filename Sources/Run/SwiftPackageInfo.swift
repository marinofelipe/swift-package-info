//
//  SwiftPackageInfo.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import ArgumentParser
import struct Foundation.URL
import Core
import App
import Reports

// MARK: - Main parsable command

public struct SwiftPackageInfo: ParsableCommand {
    public static var configuration = CommandConfiguration(
        abstract: "A tool for analyzing Swift Packages",
        discussion: """
        Provides valuable information about a given Swift Package,
        that can be used in your favor when deciding whether to
        adopt or not a Swift Package as a dependency on your app.
        """,
        version: "1.0.6",
        subcommands: [
            BinarySize.self,
            Platforms.self,
            Dependencies.self,
            FullAnalyzes.self
        ],
        defaultSubcommand: FullAnalyzes.self
    )

    static var subcommandsProviders: [InfoProvider] = [
        BinarySizeProvider.fetchInformation(for:packageContent:verbose:),
        PlatformsProvider.fetchInformation(for:packageContent:verbose:),
        DependenciesProvider.fetchInformation(for:packageContent:verbose:)
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
            .customLong("url")
        ],
        help: "URL containing the Swift Package / `Package.swift` that contains the product you want to run analyzes for."
    )
    var repositoryURL: URL

    @Option(
        name: [
            .long,
            .customShort("v")
        ],
        help: "Semantic version of the Swift Package. If not passed in the latest release is used."
    )
    var packageVersion: String?

    @Option(
        name: [
            .long,
            .customLong("product-named"),
            .customLong("product-name")
        ],
        help: "Name of the product to be checked."
    )
    var product: String

    @Flag(
        name: .long,
        help: "Increase verbosity of informational output"
    )
    var verbose = false
}

// MARK: - Common ParsableCommand extension

extension ParsableCommand {
    func runArgumentsValidation(arguments: AllArguments) throws {
        guard CommandLine.argc > 1 else { throw CleanExit.helpRequest() }

        guard arguments.repositoryURL.isValid else {
            throw CleanExit.message(
                """
                Error: Invalid argument '--repository-url <repository-url>'
                Usage: The URL must be a valid git repository URL that contains a `Package.swift`, e.g. `https://github.com/Alamofire/Alamofire`.
                """
            )
        }
    }

    func makeSwiftPackage(from arguments: AllArguments) -> SwiftPackage {
        .init(
            repositoryURL: arguments.repositoryURL,
            version: arguments.packageVersion ?? "Undefined",
            product: arguments.product
        )
    }

    func validate(
        swiftPackage: inout SwiftPackage,
        arguments: AllArguments
    ) throws -> PackageContent {
        let swiftPackageService = SwiftPackageService()
        let packageResponse = try swiftPackageService.validate(swiftPackage: swiftPackage, verbose: arguments.verbose)

        guard packageResponse.isRepositoryValid else {
            throw CleanExit.message(
                """
                Error: Invalid argument '--repository-url <repository-url>'
                Usage: The URL must be a valid git repository URL that contains a `Package.swift`, e.g. `https://github.com/Alamofire/Alamofire`.
                """
            )
        }

        if packageResponse.isTagValid == false, let latestTag = packageResponse.latestTag {
            Console.default.lineBreakAndWrite("Invalid version: \(swiftPackage.version)")
            Console.default.lineBreakAndWrite("Using latest found tag instead: \(latestTag)")

            swiftPackage.version = latestTag
        }

        guard packageResponse.isProductValid else {
            throw CleanExit.message(
                """
                Error: Invalid argument '--product <product>'
                Usage: The product should match one of the declared products on \(swiftPackage.repositoryURL).
                Found available products: \(packageResponse.availableProducts).
                """
            )
        }

        return packageResponse.packageContent
    }
}
