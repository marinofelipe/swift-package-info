//
//  SwiftPackageInfo.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import ArgumentParser
import Core
import struct Foundation.URL
import struct TSCUtility.Version

/// A command that analyzes a given Swift Package
public struct SwiftPackageInfo: ParsableCommand {
    static let estimatedSizeNote = """
    * Note: When adding a Swift Package dependency to your project, its final contributed binary size varies depending on
    the platform, user devices, etc. The app binary goes through optimization processes, such as app thinning,
    which decrease the final binary size.

    The reported size here though can give you a good general idea of the binary impact, and it can help you on making
    a decision to adopt or not such dependency. Be careful and mindful of your decision! *
    """

    public static var configuration = CommandConfiguration(
        abstract: "Check the estimated size of a Swift Package.",
        discussion: """
        Measures the estimated binary size impact of a Swift Package product,
        such as "ArgumentParser" declared on `swift-argument-parser`.

        \(estimatedSizeNote)
        """,
        version: "1.0"
    )

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

    public init() {}

    public func run() throws {
        // TODO: Check for URL validity

        guard CommandLine.argc > 2 else { throw CleanExit.helpRequest() }

        let swiftPackage = SwiftPackage(
            repositoryURL: repositoryURL,
            version: packageVersion.description,
            product: product
        )

        Console.default.lineBreakAndWrite(swiftPackage.message)

        var sizeMeasurer = SizeMeasurer()
        try sizeMeasurer.measureEmptyAppSize()
        try sizeMeasurer.measureAppSize(with: swiftPackage)
        try sizeMeasurer.cleanup()

        let increasedSize = sizeMeasurer.appWithDependencyAddedSize.amount - sizeMeasurer.emptyAppSize.amount
        let formattedIncreasedSize = URL.fileByteCountFormatter
            .string(for: increasedSize) ?? "\(increasedSize)"

        let message = """
        + -----------------------------------------------------------
        |  Empty app size: \(sizeMeasurer.emptyAppSize.formatted)
        |
        |  App size with \(swiftPackage.product): \(sizeMeasurer.appWithDependencyAddedSize.formatted)
        |
        |  Binary size increased by: \(formattedIncreasedSize)
        |
        |  \(Self.estimatedSizeNote)
        + ----------------------------------------------------------
        """

        Console.default.lineBreakAndWrite(
            .init(
                text: message,
                color: .green,
                isBold: true
            )
        )
    }
}
