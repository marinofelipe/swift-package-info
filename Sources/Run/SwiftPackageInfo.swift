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
        help: "Increase verbosity of informational output"
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

import Foundation

// TODO: Pre-step - Check Swift Package

// Info needed:
// 1. Does repository exist?
// 2. Is the tag valid?
// 3. What are the possible tags?

// All answered with:
// `curl https://api.github.com/repos/ReactiveX/RxSwift`
// `curl https://api.github.com/repos/ReactiveX/RxSwift/tags`

// 4. Is the product valid?
// 5. What are the possible products?

// Can be fetched via:
// `curl https://raw.githubusercontent.com/firebase/firebase-ios-sdk/master/Package.swift`

// Extra, e.g. on a repository info provider
// 4. dependencies
// 5. Supported platforms
// ...etc
// Can be fetched via parsing a Package.Swift:
// `curl https://raw.githubusercontent.com/firebase/firebase-ios-sdk/master/Package.swift`


//extension Array {
//    public subscript(safeIndex index: Int) -> Element? {
//        guard index >= 0, index < endIndex else { return nil }
//
//        return self[index]
//    }
//}
//
//extension SwiftPackage {
//    var repositoryName: String? {
//        repositoryURL.absoluteString.contains(".git") ?
//            repositoryURL.pathComponents[safeIndex: repositoryURL.pathComponents.count - 1] ?? repositoryURL.pathComponents.last :
//            repositoryURL.pathComponents.last
//    }
//}
//
//final class PackageManagerKKK {
//    func isRepositoryValid(swiftPackage: SwiftPackage) -> Bool {
//        return Shell.run("git clone \(swiftPackage.repositoryURL)")
//    }
//
//    func isVersionValid(swiftPackage: SwiftPackage) -> Bool {
//        Shell.run("git clone \(swiftPackage.repositoryURL)")
//    }
//}
//
//final class Client {
//    private let urlSession: URLSession
//
//    init(urlSession: URLSession = .shared) {
//        self.urlSession = urlSession
//    }
//
//    func fetchPackageDotSwift(for swiftPackage: SwiftPackage) {
//        // TODO: tbi.
//    }
//}
//
//import TSCUtility
//
//func a() {
//    let versions = Git.convertTagsToVersionMap([""])
//}
