//
//  BinarySizeProvider.swift
//  
//
//  Created by Marino Felipe on 02.01.21.
//

import Core
import Foundation

enum BinarySizeProviderError: LocalizedError, Equatable {
    case unableToGenerateArchive(errorMessage: String)
    case unableToGetBinarySizeOnDisk(underlyingError: NSError)
    case unableToRetrieveAppProject(atPath: String)
    case unexpectedError

    var errorDescription: String? {
        switch self {
            case let .unableToGenerateArchive(errorMessage):
                return "Failed to generate archive with error: \(errorMessage)"
            case let .unableToGetBinarySizeOnDisk(underlyingError):
                return "Failed to get archive size with error: \(underlyingError.localizedDescription)"
            case let .unableToRetrieveAppProject(path):
                return "Failed to get MeasurementApp project from XcodeProj at path: \(path)"
            case .unexpectedError:
                return "Unexpected failure to calculate binary size. Please run with --verbose enabled for more details."
        }
    }
}

public struct BinarySizeProvider {
    public static func fetchInformation(
        for swiftPackage: SwiftPackage,
        packageContent: PackageContent,
        verbose: Bool
    ) -> Result<ProvidedInfo, InfoProviderError> {
        let sizeMeasurer = SizeMeasurer(verbose: verbose)
        var formattedPackageBinarySize: String = ""

        do {
            formattedPackageBinarySize = try sizeMeasurer.formattedBinarySize(for: swiftPackage)
        } catch let error as LocalizedError {
            return .failure(
                .init(localizedError: error)
            )
        } catch {
            return .failure(
                .init(localizedError: BinarySizeProviderError.unexpectedError)
            )
        }

        let firstPartMessage = ConsoleMessage(
            text: "Binary size increased by ",
            color: .noColor,
            isBold: false,
            hasLineBreakAfter: false
        )
        let secondPartMessage = ConsoleMessage(
            text: formattedPackageBinarySize,
            color: .yellow,
            isBold: true,
            hasLineBreakAfter: false
        )

        return .success(
            .init(
                providerName: "Binary Size",
                messages: [
                    firstPartMessage,
                    secondPartMessage
                ]
            )
        )
    }
}
