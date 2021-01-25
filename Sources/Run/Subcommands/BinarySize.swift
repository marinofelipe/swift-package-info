//
//  BinarySize.swift
//  
//
//  Created by Marino Felipe on 03.01.21.
//

import ArgumentParser
import Core
import App
import Reports

extension SwiftPackageInfo {
    public struct BinarySize: ParsableCommand {
        static let estimatedSizeNote = """
        * Note: The estimated size doesn't consider optimizations such as app thinning.
        Its methodology is inspired by [cocoapods-size](https://github.com/google/cocoapods-size),
        and thus works by comparing archives with no bitcode and ARM64 arch.
        Such a strategy has proven to be very consistent with the size added to iOS apps downloaded and installed via TestFlight.
        """

        public static var configuration = CommandConfiguration(
            abstract: "Estimated binary size of a Swift Package product.",
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
            var swiftPackage = makeSwiftPackage(from: allArguments)
            swiftPackage.messages.forEach(Console.default.lineBreakAndWrite)

            let packageContent = try validate(swiftPackage: &swiftPackage, arguments: allArguments)

            let report = Report(swiftPackage: swiftPackage)

            BinarySizeProvider.fetchInformation(
                for: swiftPackage,
                packageContent: packageContent,
                verbose: allArguments.verbose
            )
            .onSuccess(report.generate(for:))
            .onFailure { Console.default.write($0.message) }
        }
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
