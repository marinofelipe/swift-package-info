//
//  BinarySizeProvider.swift
//  
//
//  Created by Marino Felipe on 02.01.21.
//

import Core
import Foundation

enum BinarySizeProviderError: LocalizedError, Equatable {
    case unableToGetBinarySizeOnDisk(underlyingError: NSError)
    case unableToRetrieveAppProject(atPath: String)
    case unableToClearTemporaryDerivedData(underlyingError: NSError)
    case unexpectedError

    var errorDescription: String? {
        switch self {
            case let .unableToGetBinarySizeOnDisk(underlyingError):
                return "Failed to get archive size with error: \(underlyingError.localizedDescription)"
            case let .unableToRetrieveAppProject(path):
                return "Failed to get MeasurementApp project from XcodeProj at path: \(path)"
            case let .unableToClearTemporaryDerivedData(underlyingError):
                return "Failed to get clear temporary derived data with error: \(underlyingError.localizedDescription)"
            case .unexpectedError:
                return "Unexpected failure to calculate binary size. Please run with --verbose enabled for more details."
        }
    }
}

public struct BinarySizeProvider {
    public static func fetchInformation(
        for swiftPackage: SwiftPackage,
        verbose: Bool,
        completion: (Result<ProvidedInfo, InfoProviderError>) -> Void
    ) {
        let sizeMeasurer = SizeMeasurer(verbose: verbose)
        var formattedPackageBinarySize: String = ""

        do {
            formattedPackageBinarySize = try sizeMeasurer.formattedBinarySize(for: swiftPackage)
        } catch let error as LocalizedError {
            completion(
                .failure(
                    .init(localizedError: error)
                )
            )
        } catch {
            completion(
                .failure(
                    .init(localizedError: BinarySizeProviderError.unexpectedError)
                )
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

        completion(
            .success(
                .init(
                    providerName: "Binary Size",
                    messages: [
                        firstPartMessage,
                        secondPartMessage
                    ]
                )
            )
        )
    }
}
