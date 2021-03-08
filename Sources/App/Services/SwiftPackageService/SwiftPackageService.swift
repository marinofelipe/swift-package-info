//
//  SwiftPackageService.swift
//  
//
//  Created by Marino Felipe on 09.01.21.
//

import Core
import Combine
import CombineHTTPClient
import Foundation
import HTTPClientCore

enum SwiftPackageServiceError: LocalizedError, Equatable {
    case unableToDumpPackageContent(errorMessage: String)
    case unableToFetchPackageContent(errorMessage: String)

    var errorDescription: String? {
        switch self {
            case let .unableToDumpPackageContent(errorMessage):
                return "Failed to dump package content with error: \(errorMessage)"
            case let .unableToFetchPackageContent(errorMessage):
                return "Failed to fetch package content with error: \(errorMessage)"
        }
    }
}

public struct SwiftPackageValidationResult: Equatable {
    public enum SourceInformation: Equatable {
        case local
        case remote(
                isRepositoryValid: Bool,
                isTagValid: Bool,
                latestTag: String?
             )
    }

    public let sourceInformation: SourceInformation
    public let isProductValid: Bool
    public let availableProducts: [String]
    public let packageContent: PackageContent
}

public final class SwiftPackageService {
    private let httpClient: CombineHTTPClient
    private let gitHubRequestBuilder: HTTPRequestBuilder
    private let console: Console
    private let fileManager: FileManager
    private let jsonDecoder: JSONDecoder

    init(
        httpClient: CombineHTTPClient = .default,
        gitHubRequestBuilder: HTTPRequestBuilder = .gitHub,
        console: Console = .default,
        fileManager: FileManager = .default,
        jsonDecoder: JSONDecoder = .default
    ) {
        self.httpClient = httpClient
        self.gitHubRequestBuilder = gitHubRequestBuilder
        self.console = console
        self.fileManager = fileManager
        self.jsonDecoder = jsonDecoder
    }

    public convenience init() {
        self.init(
            httpClient: .default,
            gitHubRequestBuilder: .gitHub,
            jsonDecoder: .default
        )
    }

    deinit {
        fetchToken?.cancel()
    }

    private var fetchToken: AnyCancellable?

    public func validate(
        swiftPackage: SwiftPackage,
        verbose: Bool
    ) throws -> SwiftPackageValidationResult {
        if swiftPackage.isLocal {
            return try runLocalValidation(for: swiftPackage, verbose: verbose)
        } else {
            return try runRemoteValidation(for: swiftPackage, verbose: verbose)
        }
    }

    // MARK: - Local

    private func runLocalValidation(
        for swiftPackage: SwiftPackage,
        verbose: Bool
    ) throws -> SwiftPackageValidationResult {
        let packageContent = try fetchLocalPackageContent(
            atPath: swiftPackage.url.path,
            verbose: verbose
        )

        return .init(
            sourceInformation: .local,
            isProductValid: packageContent.products
                .contains(where: \.name == swiftPackage.product),
            availableProducts: packageContent.products.map(\.name),
            packageContent: packageContent
        )
    }

    private func fetchLocalPackageContent(
        atPath path: String,
        verbose: Bool
    ) throws -> PackageContent {
        if fileManager.fileExists(atPath: path) {
            return try dumpPackageContent(
                atPath: path,
                verbose: verbose
            )
        }

        throw SwiftPackageServiceError.unableToDumpPackageContent(
            errorMessage: "Package.swift does not exist on local path: \(path)"
        )
    }

    // MARK: - Remote

    private func runRemoteValidation(
        for swiftPackage: SwiftPackage,
        verbose: Bool
    ) throws -> SwiftPackageValidationResult {
        let repositoryRequest = try gitHubRequestBuilder
            .path("/repos/\(swiftPackage.accountName)/\(swiftPackage.repositoryName)")
            .build()

        let tagsRequest = try gitHubRequestBuilder
            .path("/repos/\(swiftPackage.accountName)/\(swiftPackage.repositoryName)/git/refs/tags")
            .build()

        let repositoryRequestPublisher: AnyPublisher<
            HTTPResponse<EmptyBody, EmptyBody>,
            HTTPResponseError
        > = httpClient.run(repositoryRequest, receiveOn: .global(qos: .userInteractive))
        let tagsRequestPublisher: AnyPublisher<
            HTTPResponse<TagsResponse, EmptyBody>,
            HTTPResponseError
        > = httpClient.run(tagsRequest, receiveOn: .global(qos: .userInteractive))

        let semaphore = DispatchSemaphore(value: 0)

        var isRepositoryValid = false
        var isTagValid = false
        var latestTag: String?

        fetchToken = Publishers.Zip(repositoryRequestPublisher, tagsRequestPublisher)
            .sink { [weak console] completion in
                semaphore.signal()
                if case let .failure(error) = completion, verbose {
                    console?.lineBreakAndWrite(.init(text: error.localizedDescription, color: .red))
                }
            } receiveValue: { repositoryResponse, tagsResponse in
                isRepositoryValid = repositoryResponse.isSuccess

                if case let .success(response) = tagsResponse.value {
                    let tags = response.tags.normalized

                    isTagValid = tags
                        .map(\.name)
                        .contains(swiftPackage.version)
                    latestTag = tags.last?.name
                }
                semaphore.signal()
            }

        semaphore.wait()

        let version = isTagValid ? swiftPackage.version : latestTag ?? ""
        let packageContent = try fetchRemotePackageContent(
            for: swiftPackage,
            version: version,
            verbose: verbose
        )

        return .init(
            sourceInformation: .remote(
                isRepositoryValid: isRepositoryValid,
                isTagValid: isTagValid,
                latestTag: latestTag
            ),
            isProductValid: packageContent.products
                .contains(where: \.name == swiftPackage.product),
            availableProducts: packageContent.products.map(\.name),
            packageContent: packageContent
        )
    }

    private func fetchRemotePackageContent(
        for swiftPackage: SwiftPackage,
        version: String,
        verbose: Bool
    ) throws -> PackageContent {
        let repositoryTemporaryPath = "\(fileManager.temporaryDirectory.path)/\(swiftPackage.repositoryName)"

        if fileManager.fileExists(atPath: repositoryTemporaryPath) {
            try fileManager.removeItem(atPath: repositoryTemporaryPath)
        }

        let fetchOutput = try Shell.performShallowGitClone(
            workingDirectory: fileManager.temporaryDirectory.path,
            repositoryURLString: swiftPackage.url.absoluteString,
            branchOrTag: version,
            verbose: verbose,
            timeout: 60
        )
        guard fetchOutput.succeeded else {
            let errorMessage = String(data: fetchOutput.errorData, encoding: .utf8) ?? ""
            throw SwiftPackageServiceError.unableToFetchPackageContent(errorMessage: errorMessage)
        }

        return try dumpPackageContent(
            atPath: repositoryTemporaryPath,
            verbose: verbose
        )
    }

    // MARK: - Common

    private func dumpPackageContent(
        atPath path: String,
        verbose: Bool
    ) throws -> PackageContent {
        let dumpOutput = try Shell.run(
            "swift package dump-package",
            workingDirectory: path,
            verbose: verbose
        )

        guard dumpOutput.succeeded else {
            let errorMessage = String(data: dumpOutput.errorData, encoding: .utf8) ?? ""
            throw SwiftPackageServiceError.unableToDumpPackageContent(errorMessage: errorMessage)
        }

        return try jsonDecoder.decode(PackageContent.self, from: dumpOutput.data)
    }
}

// MARK: - Extensions

extension HTTPRequestBuilder {
    static let gitHub: HTTPRequestBuilder = .init(scheme: .https, host: "api.github.com")
}

extension CombineHTTPClient {
    static let `default`: CombineHTTPClient = .init(session: URLSession(configuration: .default))
}

extension JSONDecoder {
    static let `default`: JSONDecoder = .init()
}

// MARK: - Extensions - Tags

private extension Array where Element == TagsResponse.Tag {
    var normalized: Self {
        map(\.normalized)
    }
}

private extension TagsResponse.Tag {
    var normalized: Self {
        .init(
            name: self.name
                .replacingOccurrences(
                    of: "refs/tags/",
                    with: ""
                )
        )
    }
}
