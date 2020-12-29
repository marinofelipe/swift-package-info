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

public struct Measure {
    public static func emptyAppSize(
        fileManager: FileManager = .default
    ) -> Int {
        do {
            let currentDirectoryPath = fileManager.currentDirectoryPath
            let measurementAppPath = currentDirectoryPath + "/TempDerivedData/archive.xcarchive/Products/Applications/MeasurementApp.app"

            let url = URL(fileURLWithPath: measurementAppPath)
            let appSize = try url.sizeOnDisk()

            Printer.print("App size: \(appSize)")

            return appSize.amount
        } catch {
            print(error.localizedDescription)
            return .zero
        }
    }

    // TODO: Allow injecting sdk and arch
    public static func buildApp() {
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

        Printer.print(command)

        let output = Shell.run(command)

        guard output.succeeded else {
            return print(
                RuntimeError.xcodeBuildFailed(message: output.errorText ?? "").localizedDescription
            )
        }

        Printer.print(output.description)
    }
}
