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

        return .success(
            .init(
                providerName: "Dependencies",
                information: DependenciesInformation(externalDependencies: externalDependencies)
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

        let allTargetsNames = packageContent.targets.map(\.name)
        var otherTargetsDependenciesNames = targetDependencies.compactMap(\.target)
        otherTargetsDependenciesNames += potentialExternalDependenciesNames
            .filter { allTargetsNames.contains($0) }

        var externalDependenciesFromOtherTargets: [PackageContent.Dependency] = []
        if otherTargetsDependenciesNames.isEmpty == false {
            externalDependenciesFromOtherTargets = getExternalDependencies(
                forTargetNames: otherTargetsDependenciesNames,
                packageContent: packageContent
            )
        }

        let externalDependencies = packageContent.dependencies.filter {
            externalDependenciesNames.contains($0.name)
                || potentialExternalDependenciesNames.contains($0.name)
        }

        let allDependencies = externalDependencies + externalDependenciesFromOtherTargets

        return Array(Set(allDependencies))
            .sorted(by: { $0.name < $1.name })
    }
}

struct DependenciesInformation: Equatable, CustomConsoleMessagesConvertible {
    struct Dependency: Equatable, Encodable {
        let name: String
        let version: String?
        let branch: String?
        let revision: String?
    }

    let externalDependencies: [PackageContent.Dependency]
    let dependencies: [Dependency]

    var messages: [ConsoleMessage] { buildConsoleMessages() }

    init(externalDependencies: [PackageContent.Dependency]) {
        self.externalDependencies = externalDependencies
        self.dependencies = externalDependencies.map(Dependency.init(from:))
    }

    private func buildConsoleMessages() -> [ConsoleMessage] {
        if externalDependencies.isEmpty {
            return [
                .init(
                    text: "No third-party dependencies :)",
                    hasLineBreakAfter: false
                )
            ]
        } else {
            return externalDependencies.map { dependency -> [ConsoleMessage] in
                var messages: [ConsoleMessage] = [
                    .init(
                        text: "\(dependency.name)",
                        hasLineBreakAfter: false
                    ),
                    .init(
                        text: " v. \(dependency.requirement.range.first?.lowerBound ?? "")",
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
    }
}

extension DependenciesInformation: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(dependencies)
    }
}

extension DependenciesInformation.Dependency {
    init(from dependency: PackageContent.Dependency) {
        self.init(
            name: dependency.name,
            version: dependency.requirement.range.first?.lowerBound.description,
            branch: dependency.requirement.branch.first,
            revision: dependency.requirement.revision.first
        )
    }
}
