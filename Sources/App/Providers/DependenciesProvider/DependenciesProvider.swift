//
//  DependenciesProvider.swift
//  
//
//  Created by Marino Felipe on 24.01.21.
//

import Core
import Foundation

enum DependenciesProviderError: LocalizedError, Equatable {
    case failedToMatchProduct

    var errorDescription: String? {
        switch self {
            case .failedToMatchProduct:
                return "Failed to match product when evaluating dependencies"
        }
    }
}

public struct DependenciesProvider {
    public static func fetchInformation(
        for swiftPackage: SwiftPackage,
        packageContent: PackageContent,
        verbose: Bool
    ) -> Result<ProvidedInfo, InfoProviderError> {
        guard let product = packageContent.products.first(where: { $0.name == swiftPackage.product }) else {
            return .failure(
                .init(
                    localizedError: DependenciesProviderError.failedToMatchProduct
                )
            )
        }

        let productTargetNames = product.targets
        let externalDependencies = getExternalDependencies(
            forTargetNames: productTargetNames,
            packageContent: packageContent
        )

        let messages: [ConsoleMessage]
        if externalDependencies.isEmpty {
            messages = [
                .init(
                    text: "No third-party dependencies :)",
                    hasLineBreakAfter: false
                )
            ]
        } else {
            messages = externalDependencies.map { dependency -> [ConsoleMessage] in
                var messages: [ConsoleMessage] = [
                    .init(
                        text: "\(dependency.name) ",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: "v. \(dependency.requirement.range.first?.lowerBound ?? "")",
                        hasLineBreakAfter: false
                    )
                ]

                let isLast = dependency == externalDependencies.last
                if isLast == false {
                    messages.append(
                        .init(
                            text: " | ",
                            hasLineBreakAfter: false
                        )
                    )
                }

                return messages
            }
            .reduce(
                [],
                +
            )
        }

        return .success(
            .init(
                providerName: "Dependencies",
                messages: messages
            )
        )
    }

    private static func getExternalDependencies(
        forTargetNames targetNames: [String],
        packageContent: PackageContent
    ) -> [PackageContent.Dependency] {
        let targets = packageContent.targets.filter { targetNames.contains($0.name) }
        let targetDependencies = targets
            .map(\.dependencies)
            .reduce(
                [],
                +
            )

        let externalDependenciesNames = targetDependencies.compactMap(\.product)
        let potentialExternalDependenciesNames = targetDependencies.compactMap(\.byName)

        let otherTargetsDependenciesNames = targetDependencies.compactMap(\.target)
        var externalDependenciesFromOtherTargets: [PackageContent.Dependency] = []
        if otherTargetsDependenciesNames.isEmpty == false {
            externalDependenciesFromOtherTargets = getExternalDependencies(
                forTargetNames: otherTargetsDependenciesNames,
                packageContent: packageContent
            )
        }

        let externalDependencies = packageContent.dependencies.filter {
            externalDependenciesNames.contains($0.name) ||
                potentialExternalDependenciesNames.contains($0.name)
        }

        return externalDependencies + externalDependenciesFromOtherTargets
    }
}
