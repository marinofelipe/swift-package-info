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

public final class SwiftPackageService {
    private let httpClient: CombineHTTPClient
    private let gitHubRequestBuilder: HTTPRequestBuilder
    private let console: Console
    private let fileManager: FileManager
    private let jsonDecoder: JSONDecoder

    /// In-memory `Package.swift decoded content`. Can be used to retrieve information for Providers.
    public private(set) var storedPackageContent: PackageContent?

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

    public struct SwiftPackageValidationResult: Equatable {
        public let isRepositoryValid: Bool
        public let isTagValid: Bool
        public let latestTag: String?
        public let isProductValid: Bool
        public let availableProducts: [String]
    }

    deinit {
        fetchToken?.cancel()
    }

    private var fetchToken: AnyCancellable?

    public func validate(
        swiftPackage: SwiftPackage,
        verbose: Bool
    ) throws -> SwiftPackageValidationResult {
        let repositoryRequest = try gitHubRequestBuilder
            .path("/repos/\(swiftPackage.accountName)/\(swiftPackage.repositoryName)")
            .build()

        let tagsRequest = try gitHubRequestBuilder
            .path("/repos/\(swiftPackage.accountName)/\(swiftPackage.repositoryName)/tags")
            .build()

        let repositoryRequestPublisher: AnyPublisher<HTTPResponse<EmptyBody, EmptyBody>, HTTPResponseError> = httpClient.run(repositoryRequest, receiveOn: .global(qos: .userInteractive))
        let tagsRequestPublisher: AnyPublisher<HTTPResponse<TagsResponse, EmptyBody>, HTTPResponseError> = httpClient.run(tagsRequest, receiveOn: .global(qos: .userInteractive))

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
                    isTagValid = response.tags
                        .map(\.name)
                        .contains(swiftPackage.version)
                    latestTag = response.tags.first?.name
                }
                semaphore.signal()
            }

        semaphore.wait()

        let version = isTagValid ? swiftPackage.version : latestTag ?? ""
        let packageContent = try fetchPackageContent(
            for: swiftPackage,
            version: version,
            verbose: verbose
        )
        storedPackageContent = packageContent

        return .init(
            isRepositoryValid: isRepositoryValid,
            isTagValid: isTagValid,
            latestTag: latestTag,
            isProductValid: packageContent.products.contains(where: \.name == swiftPackage.product),
            availableProducts: packageContent.products.map(\.name)
        )
    }

    private func fetchPackageContent(for swiftPackage: SwiftPackage, version: String, verbose: Bool) throws -> PackageContent {
        let repositoryTemporaryPath = "\(fileManager.temporaryDirectory.path)/\(swiftPackage.repositoryName)"

        if fileManager.fileExists(atPath: repositoryTemporaryPath) {
            try fileManager.removeItem(atPath: repositoryTemporaryPath)
        }

        let fetchOutput = try Shell.run(
            "git clone --branch \(version) --depth 1 \(swiftPackage.repositoryURL)",
            workingDirectory: fileManager.temporaryDirectory.path,
            verbose: verbose
        )
        guard fetchOutput.succeeded else {
            let errorMessage = String(data: fetchOutput.errorData, encoding: .utf8) ?? ""
            throw SwiftPackageServiceError.unableToFetchPackageContent(errorMessage: errorMessage)
        }

        let dumpOutput = try Shell.run(
            "swift package dump-package",
            workingDirectory: repositoryTemporaryPath,
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
