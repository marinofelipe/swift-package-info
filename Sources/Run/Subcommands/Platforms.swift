//  Copyright (c) 2022 Felipe Marino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
            version: "1.3.4"
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
