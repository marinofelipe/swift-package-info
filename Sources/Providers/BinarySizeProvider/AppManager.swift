//
//  AppManager.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import Foundation
import Core
import XcodeProj

/// Provides API to work with the `measurement app`.
/// Can `generate archive`, `calculate its binary size` and `mutate the project` with a given Swift Package dependency`.
final class AppManager {
    private static let temporaryDerivedDataPath: String = "TempDerivedData"
    private static let archiveName: String = "archive.xcarchive"
    private static let archivePath: String = temporaryDerivedDataPath
        .appending("/\(archiveName)")

    private lazy var appPath: String = fileManager.currentDirectoryPath
        .appending("/MeasurementApp.xcodeproj")

    private var fullTemporaryDerivedDataPath: String {
        fileManager.currentDirectoryPath
            .appending("/\(Self.temporaryDerivedDataPath)")
    }

    private var archivedProductPath: String {
        fullTemporaryDerivedDataPath
            .appending("/\(Self.archiveName)")
            .appending("/Products/Applications/MeasurementApp.app")
    }

    private let fileManager: FileManager
    private let console: Console

    init(fileManager: FileManager = .default, console: Console = .default) {
        self.fileManager = fileManager
        self.console = console
    }

    func generateArchive() {
        let command: ConsoleMessage = """
        xcodebuild \
        archive \
        -project MeasurementApp.xcodeproj \
        -scheme MeasurementApp \
        -archivePath \(Self.archivePath) \
        -derivedDataPath \(Self.temporaryDerivedDataPath) \
        -configuration Release \
        -arch arm64 \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        ENABLE_BITCODE=NO
        """

        console.lineBreakAndWrite(command)

        let succeeded = Shell.run(command.text)
        if succeeded == false {
            console.lineBreakAndWrite(
                .init(
                    text: "Command failed...",
                    color: .red
                )
            )
        }
    }

    func calculateBinarySize() throws -> SizeOnDisk {
        do {
            let url = URL(fileURLWithPath: archivedProductPath)
            let appSize = try url.sizeOnDisk()

            console.lineBreakAndWrite(appSize.message)

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
        Shell.run("git checkout MeasurementApp.xcodeproj/")
    }
}

private extension PBXProject {
    func add(swiftPackage: SwiftPackage) throws -> XCRemoteSwiftPackageReference {
        try addSwiftPackage(
            repositoryURL: swiftPackage.repositoryURL.absoluteString,
            productName: swiftPackage.product,
            versionRequirement: .upToNextMinorVersion(swiftPackage.version),
            targetName: "MeasurementApp"
        )
    }
}
