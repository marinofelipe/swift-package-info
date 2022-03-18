//  Copyright (c) 2022 Felipe Marino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
                providerKind: .dependencies,
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
                        text: " v. \(dependency.requirement?.range.first?.lowerBound ?? "")",
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
            version: dependency.requirement?.range.first?.lowerBound.description,
            branch: dependency.requirement?.branch.first,
            revision: dependency.requirement?.revision.first
        )
    }
}
