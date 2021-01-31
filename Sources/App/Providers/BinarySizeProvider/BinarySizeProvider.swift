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
    case unableToCloneEmptyApp(errorMessage: String)
    case unableToGetBinarySizeOnDisk(underlyingError: NSError)
    case unableToRetrieveAppProject(atPath: String)
    case unexpectedError

    var errorDescription: String? {
        let step: String
        let message: String
        switch self {
            case let .unableToGenerateArchive(errorMessage):
                step = "Archiving"
                message = errorMessage
            case let .unableToCloneEmptyApp(errorMessage):
                step = "Cloning empty app"
                message = errorMessage
            case let .unableToGetBinarySizeOnDisk(underlyingError):
                step = "Reading binary size"
                message = "Failed to read binary size from archive. Details: \(underlyingError.localizedDescription)"
            case let .unableToRetrieveAppProject(path):
                step = "Read measurement app project"
                message = "Failed to get MeasurementApp project from XcodeProj at path: \(path)"
            case .unexpectedError:
                step = "Undefined"
                message = "Unexpected failure. Please run with --verbose enabled for more details."
        }

        return """
        Failed to measure binary size
        Step: \(step)
        Error: \(message)
        """
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

        let isProductDynamicLibrary = packageContent.products
            .first{ $0.name == swiftPackage.product }?
            .isDynamicLibrary ?? false

        do {
            formattedPackageBinarySize = try sizeMeasurer.formattedBinarySize(
                for: swiftPackage,
                isDynamic: isProductDynamicLibrary
            )
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
            text: "Binary size increases by ",
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
