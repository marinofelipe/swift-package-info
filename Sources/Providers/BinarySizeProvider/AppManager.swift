//
//  AppManager.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import Foundation
import Core
import XcodeProj

// MARK: - Constants

fileprivate enum Constants {
    static let appName: String = "MeasurementApp"
    static let xcodeProjName: String = "\(appName).xcodeproj"
    static let temporaryDerivedDataPath: String = "TempDerivedData"
    static let archiveName: String = "archive.xcarchive"
    static let archivePath: String = temporaryDerivedDataPath
        .appending("/")
        .appending(archiveName)
}

// MARK: - App manager

/// Provides API to work with the `measurement app`.
/// Can `generate archive`, `calculate its binary size` and `mutate the project` with a given Swift Package dependency`.
final class AppManager {
    private lazy var appPath: String = fileManager.currentDirectoryPath
        .appending("/")
        .appending(Constants.xcodeProjName)

    private var fullTemporaryDerivedDataPath: String {
        fileManager.currentDirectoryPath
            .appending("/")
            .appending(Constants.temporaryDerivedDataPath)
    }

    private var archivedProductPath: String {
        fullTemporaryDerivedDataPath
            .appending("/")
            .appending(Constants.archiveName)
            .appending("/Products/Applications/MeasurementApp.app")
    }

    private let fileManager: FileManager
    private let console: Console
    private let verbose: Bool

    init(
        fileManager: FileManager = .default,
        console: Console = .default,
        verbose: Bool
    ) {
        self.fileManager = fileManager
        self.console = console
        self.verbose = verbose
    }

    func generateArchive() {
        let command: ConsoleMessage = """
        xcodebuild \
        archive \
        -project \(Constants.xcodeProjName) \
        -scheme \(Constants.appName) \
        -archivePath \(Constants.archivePath) \
        -derivedDataPath \(Constants.temporaryDerivedDataPath) \
        -configuration Release \
        -arch arm64 \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        ENABLE_BITCODE=NO
        """

        let semaphore = DispatchSemaphore(value: 0)

        if verbose {
            console.lineBreakAndWrite(command)
        }

        Shell.run(
            command.text,
            verbose: verbose
        ) { [weak console, verbose] succeeded in
            if succeeded == false && verbose {
                console?.lineBreakAndWrite(
                    .init(
                        text: "Command failed...",
                        color: .red
                    )
                )
            }
            semaphore.signal()
        }

        semaphore.wait()
    }

    func calculateBinarySize() throws -> SizeOnDisk {
        do {
            let url = URL(fileURLWithPath: archivedProductPath)
            let appSize = try url.sizeOnDisk()

            if verbose { console.lineBreakAndWrite(appSize.message) }

            return appSize
        } catch {
            throw BinarySizeProviderError.unableToGetBinarySizeOnDisk(underlyingError: error as NSError)
        }
    }

    func add(asDependency swiftPackage: SwiftPackage) throws {
        let xcodeProj = try XcodeProj(path: .init(appPath))

        guard let appProject = xcodeProj.pbxproj.projects.first else {
            throw BinarySizeProviderError.unableToRetrieveAppProject(atPath: appPath)
        }

        let swiftPackage = try appProject.add(swiftPackage: swiftPackage)
        xcodeProj.pbxproj.add(object: swiftPackage)

        try xcodeProj.write(path: .init(appPath))
    }

    func cleanupTemporaryDerivedData() throws {
        do {
            try fileManager.removeItem(atPath: fullTemporaryDerivedDataPath)
        } catch {
            throw BinarySizeProviderError.unableToClearTemporaryDerivedData(underlyingError: error as NSError)
        }
    }

    func removeAppDependencies() {
        Shell.run(
            "git checkout \(Constants.xcodeProjName)",
            verbose: verbose,
            completion: nil
        )
    }
}

// MARK: - PBXProject: add(swiftPackage:targetName:)

private extension PBXProject {
    func add(swiftPackage: SwiftPackage, targetName: String = Constants.appName) throws -> XCRemoteSwiftPackageReference {
        try addSwiftPackage(
            repositoryURL: swiftPackage.repositoryURL.absoluteString,
            productName: swiftPackage.product,
            versionRequirement: .upToNextMinorVersion(swiftPackage.version),
            targetName: targetName
        )
    }
}
