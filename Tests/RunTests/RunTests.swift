//
//  RunTests.swift
//  
//
//  Created by Marino Felipe on 28.12.20.
//

import XCTest

final class RunTests: XCTestCase {
    func testHelp() throws {
        guard #available(macOS 10.13, *) else { return }

        let executableURL = productsDirectory.appendingPathComponent("swift-package-info")

        let process = Process()
        process.executableURL = executableURL
        process.arguments = ["--help"]

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

        XCTAssertEqual(
            outputContent,
            """
            OVERVIEW: A tool for analyzing Swift Packages

            Provides valuable information about a given Swift Package,\nthat can be used in your favor when deciding whether to\nadopt or not a Swift Package as a dependency on your app.

            USAGE: swift-package-info <subcommand>

            OPTIONS:
              --version               Show the version.
              -h, --help              Show help information.\n\nSUBCOMMANDS:
              binary-size             Check the estimated size of a Swift Package.
              full-analyzes (default) Get all available information about a Swift Package

              See \'swift-package-info help <subcommand>\' for detailed help.

            """
        )
        XCTAssertEqual(errorContent, "")
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

    static var allTests = [
        ("testHelp", testHelp),
    ]
}
