//
//  SwiftPackageInfo.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import ArgumentParser
import Core
import struct Foundation.URL

/// A command that analyzes a given Swift Package
public struct SwiftPackageInfo: ParsableCommand {
    public static var configuration = CommandConfiguration(
        abstract: "Check the estimated size of a Swift Package.",
        discussion: """
        Provides you with key information about a Swift Package product,
        such as "ArgumentParser" declared on `swift-argument-parser`.

        Estimation of binary size it would contribute to your app,
        its direct dependencies, and more...
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
    var packageVersion: String

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
            version: packageVersion,
            product: product
        )

        Console.default.lineBreakAndWrite(swiftPackage.message)

        var sizeMeasurer = SizeMeasurer()
        try sizeMeasurer.measureEmptyAppSize()
        try sizeMeasurer.measureAppSize(with: swiftPackage)

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
        |  * Note that the sizes reported are an estimation. When adding this dependency to your project, for the final user it will go through
        |  optimization processes, such as app thinning, which will decrease the final size the dependency adds to that binary.
        |  Even then, the added size gives a good idea of the amount of source code you're adding to your app. Be careful and mindful of your decision! *
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
