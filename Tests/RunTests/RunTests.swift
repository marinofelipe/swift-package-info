//  Copyright (c) 2025 Felipe Marino
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

import XCTest
import Foundation

@available(macOS 10.13, *)
final class RunTests: XCTestCase {
  func testWithInvalidRemoteURL() throws {
    try runToolProcessAndAssert(
      command: "--url somethingElse --package-version 6.0.0 --product RxSwift",
      expectedOutput: """
        Error: Invalid argument '--url <url>'
        Usage: The URL must be either:
        - A valid git repository URL that contains a `Package.swift`, e.g `https://github.com/Alamofire/Alamofire`; or
        - A relative local directory path that has a `Package.swift`, e.g. `../other-dir/my-project`
        
        """,
      expectedError: ""
    )
  }

  func testLocalURLWithoutPackage() throws {
    try runToolProcessAndAssert(
      command: "--url ../path",
      expectedOutput: """
        Error: Invalid argument '--url <url>'
        Usage: The URL must be either:
        - A valid git repository URL that contains a `Package.swift`, e.g `https://github.com/Alamofire/Alamofire`; or
        - A relative local directory path that has a `Package.swift`, e.g. `../other-dir/my-project`
        
        """,
      expectedError: ""
    )
  }

  func testHelp() throws {
    let expectedOutput = """
      OVERVIEW: A tool for analyzing Swift Packages
      
      Provides valuable information about a given Swift Package,\nthat can be used in your favor when deciding whether to\nadopt or not a Swift Package as a dependency on your app.
      
      USAGE: swift-package-info <subcommand>
      
      OPTIONS:
        --version               Show the version.
        -h, --help              Show help information.\n\nSUBCOMMANDS:
        binary-size             Estimated binary size of a Swift Package product.
        platforms               Shows platforms supported b a Package product.
        dependencies            List dependencies of a Package product.
        full-analyzes (default) All available information about a Swift Package\n                          product.
      
        See \'swift-package-info help <subcommand>\' for detailed help.
      
      """

    try runToolProcessAndAssert(
      command: "--help",
      expectedOutput: expectedOutput,
      expectedError: ""
    )
  }

  /// Returns path to the built products directory.
  var productsDirectory: URL {
#if os(macOS)
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
      return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("couldn't find the products directory")
#else
    return Bundle.main.bundleURL
#endif
  }

  // MARK: - Helpers

  private func runToolProcessAndAssert(
    _ file: StaticString = #filePath,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    command: String,
    expectedOutput: String?,
    expectedError: String?
  ) throws {
    let commands = command.split(whereSeparator: \.isWhitespace)

    let arguments: [String]
    if commands.count > 1 {
      arguments = commands.map { String($0) }
    } else {
      arguments = command
        .split { [" -", " --"].contains(String($0)) }
        .map { String($0) }
    }

    let executableURL = productsDirectory.appendingPathComponent("swift-package-info")

    let process = Process()
    process.executableURL = executableURL
    process.arguments = arguments

    let outputPipe = Pipe()
    process.standardOutput = outputPipe

    let errorPipe = Pipe()
    process.standardError = errorPipe

    try process.run()
    process.waitUntilExit()

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let outputContent = String(data: outputData, encoding: .utf8)
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorContent = String(data: errorData, encoding: .utf8)

    XCTAssertEqual(outputContent, expectedOutput, file: file, line: line)
    XCTAssertEqual(errorContent, expectedError, file: file, line: line)
  }
}
