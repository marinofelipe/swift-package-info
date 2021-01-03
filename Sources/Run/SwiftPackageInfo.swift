//
//  SwiftPackageInfo.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import ArgumentParser
import struct Foundation.URL
import struct TSCUtility.Version
import Core
import Providers
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
        version: "1.0",
        subcommands: [BinarySize.self, FullAnalyzes.self],
        defaultSubcommand: FullAnalyzes.self
    )

    static var subcommandsProviders: [InfoProvider] = [
        BinarySize.fetchProvidedInfo(for:verbose:completion:)
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
        help: "Semantic version of the Swift Package." // If not passed the latest one will be used instead.
    )
    var packageVersion: Version

    @Option(
        name: [
            .long,
            .customLong("product-named"),
            .customLong("product-name")
        ],
        help: "Name of the product to be checked."
    )
    var product: String

    // TODO: tbi.
    @Flag(
        name: .long,
        help: "Output all steps of a running analyzes"
    )
    var verbose = false
}

// MARK: - Common ParsableCommand extension

extension ParsableCommand {
    func runArgumentsValidation(arguments: AllArguments) throws {
        guard CommandLine.argc > 2 else { throw CleanExit.helpRequest() }

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
            version: arguments.packageVersion.description,
            product: arguments.product
        )
    }
}
