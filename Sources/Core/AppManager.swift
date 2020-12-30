//
//  AppManager.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import Foundation
import XcodeProj

/// Provides API to work with the `measurement app`.
/// Can `generate archive`, `calculate its binary size` and `mutate the project` with a given Swift Package dependency`.
struct AppManager {
    private lazy var appPath: String = {
        fileManager.currentDirectoryPath
            .appending("/MeasurementApp.xcodeproj")
    }()

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func generateArchive() {
        let command: ConsoleMessage = """
        xcodebuild \
        archive \
        -project MeasurementApp.xcodeproj \
        -scheme MeasurementApp \
        -archivePath TempDerivedData/archive.xcarchive \
        -derivedDataPath TempDerivedData \
        -sdk iphoneos \
        -configuration Release
        """

        Console.default.lineBreakAndWrite(command)

        let succeeded = Shell.run(command.text)
        if succeeded == false {
            Console.default.lineBreakAndWrite(
                .init(
                    text: "Command failed...",
                    color: .red
                )
            )
        }
    }

    func calculateBinarySize() throws -> SizeOnDisk {
        do {
            let currentDirectoryPath = fileManager.currentDirectoryPath
            let measurementAppPath = currentDirectoryPath + "/TempDerivedData/archive.xcarchive/Products/Applications/MeasurementApp.app"

            let url = URL(fileURLWithPath: measurementAppPath)
            let appSize = try url.sizeOnDisk()

            Console.default.lineBreakAndWrite(appSize.message)

            return appSize
        } catch {
            throw RuntimeError.unableToGetBinarySizeOnDisk(underlyingError: error as NSError)
        }
    }

    mutating func addAlamofireDependency() throws {
        let xcodeProj = try XcodeProj(path: .init(appPath))

        guard let appProject = xcodeProj.pbxproj.projects.first else {
            throw RuntimeError.unableToRetrieveAppProject(atPath: appPath)
        }

        let swiftPackage = try appProject.addSwiftPackage(
            repositoryURL: "https://github.com/Alamofire/Alamofire",
            productName: "Alamofire",
            versionRequirement: .upToNextMinorVersion("5.4.0"),
            targetName: "MeasurementApp"
        )
        xcodeProj.pbxproj.add(object: swiftPackage)

        try xcodeProj.write(path: .init(appPath))
    }
}
