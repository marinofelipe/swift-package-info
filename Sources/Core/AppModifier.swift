//
//  AppModifier.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import Foundation
import XcodeProj

struct AppModifier {
    private lazy var appPath: String = {
        fileManager.currentDirectoryPath
            .appending("/MeasurementApp.xcodeproj")
    }()

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    mutating func addAlamofireDependency() throws {
        let project = try XcodeProj(path: .init(appPath))

        guard let swiftPackage = try project.pbxproj.projects.first?.addSwiftPackage(
            repositoryURL: "https://github.com/Alamofire/Alamofire",
            productName: "Alamofire",
            versionRequirement: .upToNextMinorVersion("5.4.0"),
            targetName: "MeasurementApp"
        ) else {
            fatalError() // throw error
        }

        project.pbxproj.add(object: swiftPackage)

        try project.write(path: .init(appPath))
    }
}
