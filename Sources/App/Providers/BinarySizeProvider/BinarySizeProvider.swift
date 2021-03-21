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
    case unexpectedError(underlyingError: NSError, isVerbose: Bool)

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
            case let .unexpectedError(underlyingError, isVerboseOn):
                step = "Undefined"
                message = """
                Unexpected failure. \(underlyingError.description).
                \(isVerboseOn ? "" : "Please run with --verbose enabled for more details.")
                """
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
        let sizeMeasurer = defaultSizeMeasurer(verbose)
        var binarySize: SizeOnDisk = .zero

        let isProductDynamicLibrary = packageContent.products
            .first{ $0.name == swiftPackage.product }?
            .isDynamicLibrary ?? false

        do {
            binarySize = try sizeMeasurer(
                swiftPackage,
                isProductDynamicLibrary
            )
        } catch let error as LocalizedError {
            return .failure(
                .init(localizedError: error)
            )
        } catch {
            return .failure(
                .init(
                    localizedError: BinarySizeProviderError.unexpectedError(
                        underlyingError: error as NSError,
                        isVerbose: verbose
                    )
                )
            )
        }

        return .success(
            .init(
                providerName: "Binary Size",
                providerKind: .binarySize,
                information: BinarySizeInformation(
                    binarySize: binarySize
                )
            )
        )
    }
}

struct BinarySizeInformation: Equatable, Encodable, CustomConsoleMessagesConvertible {
    private let amount: Int
    private let formatted: String

    var messages: [ConsoleMessage] { buildConsoleMessages() }

    init(binarySize: SizeOnDisk) {
        self.amount = binarySize.amount
        self.formatted = binarySize.formatted
    }

    private enum CodingKeys: String, CodingKey {
        case amount
        case formatted
    }

    private func buildConsoleMessages() -> [ConsoleMessage] {
        [
            .init(
                text: "Binary size increases by ",
                color: .noColor,
                isBold: false,
                hasLineBreakAfter: false
            ),
            .init(
                text: formatted,
                color: .yellow,
                isBold: true,
                hasLineBreakAfter: false
            )
        ]
    }
}

#if DEBUG
var defaultSizeMeasurer: (Bool) -> SizeMeasuring = { verbose in
    SizeMeasurer(verbose: verbose).binarySize
}
#else
let defaultSizeMeasurer: (Bool) -> SizeMeasuring = { verbose in
    SizeMeasurer(verbose: verbose).binarySize
}
#endif
