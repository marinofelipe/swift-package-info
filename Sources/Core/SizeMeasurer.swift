//
//  Measure.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import Foundation

enum RuntimeError: LocalizedError, Equatable {
    case xcodeBuildFailed(message: String)

    var errorDescription: String? {
        switch self {
            case let .xcodeBuildFailed(message):
                return "Failed to build measurement app with error: \(message)"
        }
    }
}

public struct SizeMeasurer {
    public private(set) var emptyAppSize: SizeOnDisk = .empty
    public private(set) var appWithDependencyAddedSize: SizeOnDisk = .empty

    private var appModifier: AppModifier

    public init() {
        self.init(appModifier: .init())
    }

    init(appModifier: AppModifier = .init()) {
        self.appModifier = appModifier
    }

    public mutating func measureEmptyAppSize() {
        Console.default.lineBreakAndWrite(
            "Measuring empty app size",
            color: .green,
            bold: true
        )

        buildApp()
        emptyAppSize = getAppSize()
    }

    public mutating func measureAppSizeWithAlamofire() throws {
        Console.default.lineBreakAndWrite(
            "Measuring app size with added dependency",
            color: .green,
            bold: true
        )

        try appModifier.addAlamofireDependency()
        buildApp()
        appWithDependencyAddedSize = getAppSize()
    }

    private func getAppSize(fileManager: FileManager = .default) -> SizeOnDisk {
        do {
            let currentDirectoryPath = fileManager.currentDirectoryPath
            let measurementAppPath = currentDirectoryPath + "/TempDerivedData/archive.xcarchive/Products/Applications/MeasurementApp.app"

            let url = URL(fileURLWithPath: measurementAppPath)
            let appSize = try url.sizeOnDisk()

            Console.default.lineBreakAndWrite(
                "Calculated size: \(appSize)",
                color: .yellow
            )

            return appSize
        } catch {
            print(error.localizedDescription)
            return .empty
        }
    }

    private func buildApp() {
        let command =
            """
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

        let succeeded = Shell.run(command)

        if succeeded == false {
            Console.default.lineBreakAndWrite(
                "Command failed...",
                color: .red
            )
        }
    }
}
