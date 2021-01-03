//
//  BinarySize.swift
//  
//
//  Created by Marino Felipe on 03.01.21.
//

import ArgumentParser
import Core
import Providers
import Reports

extension SwiftPackageInfo {
    public struct BinarySize: ParsableCommand {
        // FIXME: Provide a better note around estimation that is done and how accurate it is
        static let estimatedSizeNote = """
        * Note: The estimated size doesn't consider optimizations such as app thinning, but they've shown
        to be reliably on our latest measurements, run with Xcode 12.3, Swift 5.3, and comparing archives made
        with bitcode disabled.
        As Example: An app with/without RxSwift has ***kb and ***kb when downloaded via TestFlight,
        while the tool reports ***kb.
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

        @OptionGroup var allArguments: AllArguments

        public init() {}

        public func run() throws {
            try runArgumentsValidation(arguments: allArguments)
            let swiftPackage = makeSwiftPackage(from: allArguments)
            swiftPackage.messages.forEach(Console.default.lineBreakAndWrite)

            // TODO: Check Package.swift to see if repository URL, version and product are valid, before moving on.

            let report = Report(swiftPackage: swiftPackage)

            Self.fetchProvidedInfo(
                for: swiftPackage,
                verbose: allArguments.verbose
            ) { result in
                result
                    .onSuccess(report.generate(for:))
                    .onFailure { Console.default.write($0.message) }
            }
        }
    }
}

extension SwiftPackageInfo.BinarySize {
    static func fetchProvidedInfo(
        for swiftPackage: SwiftPackage,
        verbose: Bool,
        completion: (Result<ProvidedInfo, InfoProviderError>) -> Void
    ) {
        BinarySizeProvider.fetchInformation(
            for: swiftPackage,
            verbose: verbose,
            completion: completion
        )
    }
}

extension SwiftPackage: CustomConsoleMessagesConvertible {
    public var messages: [ConsoleMessage] {
        [
            .init(
                text: "Identified Swift Package:",
                color: .green,
                isBold: true,
                hasLineBreakAfter: false
            ),
            .init(
                text: description,
                color: .noColor,
                isBold: false
            )
        ]
    }
}
