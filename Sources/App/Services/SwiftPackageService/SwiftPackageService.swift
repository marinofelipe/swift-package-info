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

import Core
import Combine
import CombineHTTPClient
import Foundation
import HTTPClientCore

import Basics
import PackageModel
import SourceControl
import TSCBasic
import TSCUtility

public struct SwiftPackageValidationResult {
  public enum SourceInformation: Equatable {
    case local
    case remote(
      isRepositoryValid: Bool,
      tagState: ResourceState,
      latestTag: String?
    )
  }

  public let sourceInformation: SourceInformation
  public let isProductValid: Bool
  public let availableProducts: [String]
  public let package: Package
}

extension SwiftPackageValidationResult {
  init(
    from package: Package,
    product: String,
    sourceInformation: SourceInformation
  ) {
    self.init(
      sourceInformation: sourceInformation,
      isProductValid: package.products.contains(where: \.name == product),
      availableProducts: package.products.map(\.name),
      package: package
    )
  }
}

public final class SwiftPackageService {
  private let fileManager: FileManager
  private let packageLoader: PackageLoader
  private let repositoryProvider: RepositoryProvider

  init(
    fileManager: FileManager = .default,
    packageLoader: PackageLoader = .live,
    repositoryProvider: RepositoryProvider
  ) {
    self.fileManager = fileManager
    self.packageLoader = packageLoader
    self.repositoryProvider = repositoryProvider
  }

  public convenience init() {
    self.init(repositoryProvider: GitRepositoryProvider())
  }

  public func validate(
    swiftPackage: SwiftPackage,
    verbose: Bool
  ) async throws -> SwiftPackageValidationResult {
    await Console.default.lineBreakAndWrite("swift-package-info built with Swift Toolchain: \(ToolsVersion.current)")

    let swiftVersionOutput = try await Shell.run("xcrun swift -version", verbose: false)
    let swiftVersion = String(data: swiftVersionOutput.data, encoding: .utf8) ?? "<undefined>"

    await Console.default.write("Current user Swift Toolchain: \(swiftVersion)")

    if swiftPackage.isLocal {
      return try await runLocalValidation(for: swiftPackage, verbose: verbose)
    } else {
      return try await runRemoteValidation(for: swiftPackage, verbose: verbose)
    }
  }

  // MARK: - Local

  private func runLocalValidation(
    for swiftPackage: SwiftPackage,
    verbose: Bool
  ) async throws -> SwiftPackageValidationResult {
    .init(
      from: try await fetchLocalPackage(atPath: swiftPackage.url.path),
      product: swiftPackage.product,
      sourceInformation: .local
    )
  }

  private func fetchLocalPackage(atPath path: String) async throws -> Package {
    let absolutePath = AbsolutePath.currentDir.appending(path)
    return try await packageLoader.load(absolutePath)
  }

  // MARK: - Remote

  private func runRemoteValidation(
    for swiftPackage: SwiftPackage,
    verbose: Bool
  ) async throws -> SwiftPackageValidationResult {
    return try await withTemporaryDirectory(prefix: "spm-package-info-run-") { tempDirPath in
      let repositoryManager = RepositoryManager(
        fileSystem: localFileSystem,
        path: tempDirPath,
        provider: repositoryProvider,
        initializationWarningHandler: { s in
          print(s)
        }
      )

      let repositoryHandle = try await fetchRepository(
        repositoryManager: repositoryManager,
        swiftPackage: swiftPackage
      )

      let cloneDirPath = tempDirPath.appending(swiftPackage.repositoryName)

      let workingCopy = try repositoryHandle.createWorkingCopy(
        at: cloneDirPath,
        editable: false
      )

      let repositoryTags = try workingCopy.getSemVerOrderedTags()
      
      let tagState: ResourceState

      switch swiftPackage.resolution {
      case let .version(version):
        let resolvedTag: String
        if version == ResourceState.undefined.description {
          tagState = .undefined
          resolvedTag = repositoryTags.last ?? ""
        } else if repositoryTags.contains(version) {
          tagState = .valid
          resolvedTag = version
        } else {
          tagState = .invalid
          resolvedTag = repositoryTags.last ?? ""
        }

        try workingCopy.checkout(tag: resolvedTag)
      case let .revision(revision):
        tagState = .undefined
        try workingCopy.checkout(revision: Revision(identifier: revision))
      }

      let package = try await packageLoader.load(cloneDirPath)

      return .init(
        from: package,
        product: swiftPackage.product,
        sourceInformation: .remote(
          isRepositoryValid: true,
          tagState: tagState,
          latestTag: repositoryTags.last
        )
      )
    }
  }

  private func fetchRepository(
    repositoryManager: RepositoryManager,
    swiftPackage: SwiftPackage
  ) async throws -> RepositoryManager.RepositoryHandle {
    let observability = ObservabilitySystem { print("\($0): \($1)") }

    return try await withCheckedThrowingContinuation { continuation in
      repositoryManager.lookup(
        package: PackageIdentity(url: "\(swiftPackage.url)"),
        repository: RepositorySpecifier(url: "\(swiftPackage.url)"),
        skipUpdate: false,
        observabilityScope: observability.topScope,
        delegateQueue: .main,
        callbackQueue: .main
      ) { result in
        switch result {
        case let .success(handle):
          continuation.resume(returning: handle)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}

// MARK: - Helpers

private extension WorkingCheckout {
  /// Get repository tags ordered by semantic versioning
  /// it attempts to normalize the tags by removing occurrences of `v`
  func getSemVerOrderedTags() throws -> [String] {
    try getTags().sorted(
      by: {
        guard
          let versionA = Version($0.removingCharacterV),
          let versionB = Version($1.removingCharacterV)
        else {
          return $0.compare(
            $1,
            options: .numeric
          ) == .orderedAscending
        }

        return versionA < versionB
      }
    )
  }
}

private extension String {
  var removingCharacterV: String {
    replacingOccurrences(of: "v", with: "")
  }
}
