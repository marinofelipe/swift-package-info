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
        version: "1.1.0",
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
            .customLong("path"),
            .customLong("local-path"),
        ],
        help: """
        Either a valid git repository URL or a local directory path that contains a `Package.swift`
        """
    )
    var url: URL

    @Option(
        name: [
            .long,
            .customShort("v")
        ],
        help: "Semantic version of the Swift Package. If not passed in the latest release is used"
    )
    var packageVersion: String?

    @Option(
        name: [
            .long,
            .customLong("product-named"),
            .customLong("product-name")
        ],
        help: "Name of the product to be checked. If not passed in the first available product is used"
    )
    var product: String?

    @Flag(
        name: .long,
        help: "Increase verbosity of informational output"
    )
    var verbose = false
}

// MARK: - Common ParsableCommand extension

extension ParsableCommand {
    func runArgumentsValidation(arguments: AllArguments) throws {
        guard CommandLine.argc > 0 else { throw CleanExit.helpRequest() }

        let isValidRemoteURL = arguments.url.isValidRemote
        let isValidLocalDirectory = try? arguments.url.isLocalDirectoryContainingPackageDotSwift()

        guard isValidRemoteURL || isValidLocalDirectory == true else {
            throw CleanExit.message(
                """
                Error: Invalid argument '--url <url>'
                Usage: The URL must be either:
                - A valid git repository URL that contains a `Package.swift`, e.g `https://github.com/Alamofire/Alamofire`; or
                - A local directory path that has a `Package.swift`, e.g. `../other-dir/my-project`
                """
            )
        }
    }

    func makeSwiftPackage(from arguments: AllArguments) -> SwiftPackage {
        .init(
            url: arguments.url,
            isLocal: arguments.url.isValidRemote ? false : true,
            version: arguments.packageVersion ?? "Undefined",
            product: arguments.product ?? "Undefined"
        )
    }

    func validate(
        swiftPackage: inout SwiftPackage,
        verbose: Bool
    ) throws -> PackageContent {
        let swiftPackageService = SwiftPackageService()
        let packageResponse = try swiftPackageService.validate(
            swiftPackage: swiftPackage,
            verbose: verbose
        )

        switch packageResponse.sourceInformation {
        case let .remote(isRepositoryValid, isTagValid, latestTag):
            guard isRepositoryValid else {
                throw CleanExit.message(
                    """
                    Error: Invalid argument '--url <url>'
                    Usage: The URL must be a valid git repository URL that contains
                    a `Package.swift`, e.g `https://github.com/Alamofire/Alamofire`
                    """
                )
            }

            if isTagValid == false, let latestTag = latestTag {
                Console.default.lineBreakAndWrite("Invalid version: \(swiftPackage.version)")
                Console.default.lineBreakAndWrite("Using latest found tag instead: \(latestTag)")

                swiftPackage.version = latestTag
            }
        case .local:
            break
        }

        guard let firstProduct = packageResponse.availableProducts.first else {
            throw CleanExit.message(
                "Error: \(swiftPackage.url) doesn't contain any product declared on Package.swift"
            )
        }

        if packageResponse.isProductValid == false {
            Console.default.lineBreakAndWrite("Invalid product: \(swiftPackage.product)")
            Console.default.lineBreakAndWrite("Using first found product instead: \(firstProduct)")

            swiftPackage.product = firstProduct
        }

        return packageResponse.packageContent
    }
}
