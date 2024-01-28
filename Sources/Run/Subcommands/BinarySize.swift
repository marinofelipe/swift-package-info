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
  public struct BinarySize: AsyncParsableCommand {
    static let estimatedSizeNote = """
        * Note: The estimated size may not reflect the exact amount since it doesn't account optimizations such as app thinning.
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
      version: SwiftPackageInfo.configuration.version
    )

    @OptionGroup var allArguments: AllArguments

    public init() {}

    public func run() async throws {
      try runArgumentsValidation(arguments: allArguments)
      var swiftPackage = makeSwiftPackage(from: allArguments)
      swiftPackage.messages.forEach(Console.default.lineBreakAndWrite)

      let package = try await validate(
        swiftPackage: &swiftPackage,
        verbose: allArguments.verbose
      )

      let report = Report(swiftPackage: swiftPackage)

      let packageWrapper = PackageWrapper(from: package)

      try BinarySizeProvider.fetchInformation(
        for: swiftPackage,
        package: packageWrapper,
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
