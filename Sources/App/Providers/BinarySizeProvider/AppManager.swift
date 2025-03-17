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

internal import Foundation
internal import Basics
internal import Core
internal import XcodeProj

// MARK: - Constants

fileprivate enum Constants {
  static let appName: String = "MeasurementApp"
  static let clonedRepoName: String = "swift-package-info"
  static let xcodeProjName: String = "\(appName).xcodeproj"
  static let xcodeProjPath: String = "\(clonedRepoName)/\(xcodeProjName)"
  static let archiveName: String = "archive.xcarchive"
}

// MARK: - App manager

/// Provides API to work with the `measurement app`.
/// Can `generate archive`, `calculate its binary size` and `mutate the project` with a given Swift Package dependency`.
final class AppManager {
  private lazy var appPath: String = fileManager.currentDirectoryPath
    .appending("/")
    .appending(Constants.xcodeProjPath)

  private lazy var emptyAppDirectoryPath: String = fileManager.currentDirectoryPath
    .appending("/")
    .appending(Constants.clonedRepoName)

  private lazy var archivedPath: String = fileManager.temporaryDirectory
    .path
    .appending("/")
    .appending(Constants.archiveName)

  private lazy var archivedProductPath: String = fileManager.temporaryDirectory
    .path
    .appending("/")
    .appending(Constants.archiveName)
    .appending("/Products/Applications/MeasurementApp.app")

  private let fileManager: FileManager
  private let console: Console
  private let verbose: Bool
  private let xcconfig: URL?

  init(
    fileManager: FileManager = .default,
    console: Console,
    xcconfig: URL?,
    verbose: Bool
  ) {
    self.fileManager = fileManager
    self.console = console
    self.xcconfig = xcconfig
    self.verbose = verbose
  }

  func cloneEmptyApp() async throws {
    do {
      try await Shell.performShallowGitClone(
        workingDirectory: fileManager.currentDirectoryPath,
        repositoryURLString: "https://github.com/marinofelipe/swift-package-info",
        branchOrTag: "1.5.0", // latest stable release to avoid issues while developing on the main branch
        verbose: verbose
      )
    } catch {
      throw BinarySizeProviderError.unableToCloneEmptyApp(errorMessage: error.localizedDescription)
    }
  }

  func cleanUp() throws {
    if fileManager.fileExists(atPath: emptyAppDirectoryPath) {
      try fileManager.removeItem(atPath: emptyAppDirectoryPath)
    }
  }

  func generateArchive() async throws {
    let workingDirectory = fileManager.currentDirectoryPath
    var cmdXCConfig: String = ""
    if let xcconfig, let customXCConfigURL = URL(string: workingDirectory)?.appendingPathComponent(xcconfig.path) {
      cmdXCConfig = "-xcconfig \(customXCConfigURL.path)"
    }

    let command: ConsoleMessage = """
        xcodebuild \
        archive \
        -project \(Constants.xcodeProjPath) \
        -scheme \(Constants.appName) \
        -archivePath \(archivedPath) \
        -configuration Release \
        \(cmdXCConfig) \
        -arch arm64 \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        ENABLE_BITCODE=NO
        """

    if verbose {
      await console.lineBreakAndWrite(command)
    }

    let output = try await Shell.run(
      command.text,
      workingDirectory: workingDirectory,
      verbose: verbose,
      timeout: nil
    )

    if output.succeeded == false {
      if verbose {
        await console.lineBreakAndWrite(
          .init(
            text: "Command failed...",
            color: .red
          )
        )
      }

      let errorMessage = String(data: output.errorData, encoding: .utf8) ?? ""
      throw BinarySizeProviderError.unableToGenerateArchive(errorMessage: errorMessage)
    }
  }

  func calculateBinarySize() async throws -> SizeOnDisk {
    do {
      let url = URL(fileURLWithPath: archivedProductPath)
      let appSize = try await url.sizeOnDisk()

      if verbose {
        await console.lineBreakAndWrite(appSize.message)
      }

      return appSize
    } catch {
      throw BinarySizeProviderError.unableToGetBinarySizeOnDisk(
        underlyingError: error as NSError
      )
    }
  }

  func add(
    asDependency swiftPackage: PackageDefinition,
    isDynamic: Bool
  ) throws {
    let xcodeProj = try XcodeProj(path: .init(appPath))

    guard let appProject = xcodeProj.pbxproj.projects.first else {
      throw BinarySizeProviderError.unableToRetrieveAppProject(atPath: appPath)
    }

    switch swiftPackage.source {
    case let .local(path):
      let relativePath = path.relative(to: .currentDir)
      let packageReference = try appProject.addLocal(
        swiftPackage: swiftPackage,
        relativePath: relativePath
      )
      xcodeProj.pbxproj.add(object: packageReference)
    case .remote:
      if let packageReference = try appProject.addRemote(swiftPackage: swiftPackage) {
        xcodeProj.pbxproj.add(object: packageReference)
      }
    }

    try xcodeProj.write(path: .init(appPath))

    if isDynamic {
      let packageDependency = appProject.targets
        .first?
        .packageProductDependencies
        .first
      let packageBuildFile = PBXBuildFile(product: packageDependency)

      let embedFrameworksBuildPhase = appProject.targets
        .first?
        .embedFrameworksBuildPhases()
        .first
      embedFrameworksBuildPhase?.files?.append(packageBuildFile)

      try xcodeProj.write(path: .init(appPath))
    }
  }
}

// MARK: - PBXProject: add(swiftPackage:targetName:)

private extension PBXProject {
  func addRemote(
    swiftPackage: PackageDefinition,
    targetName: String = Constants.appName
  ) throws -> XCRemoteSwiftPackageReference? {
    let requirement: XCRemoteSwiftPackageReference.VersionRequirement
    switch swiftPackage.source.remoteResolution {
    case let .revision(revision):
      requirement = .revision(revision)
    case let .version(tag):
      requirement = .exact(
        tag.trimmingCharacters(
          in: CharacterSet.decimalDigits.inverted
        )
      )
    case .none:
      return nil
    }

    return try addSwiftPackage(
      repositoryURL: swiftPackage.url.absoluteString,
      productName: swiftPackage.product,
      versionRequirement: requirement,
      targetName: targetName
    )
  }

  func addLocal(
    swiftPackage: PackageDefinition,
    relativePath: RelativePath,
    targetName: String = Constants.appName
  ) throws -> XCSwiftPackageProductDependency {
    try addLocalSwiftPackage(
      // The path is adjusted considering the location of the cloned MeasurementApp is
      // different than the the relative path to the current dir
      path: .init("../\(relativePath.pathString)"),
      productName: swiftPackage.product,
      targetName: targetName
    )
  }
}
