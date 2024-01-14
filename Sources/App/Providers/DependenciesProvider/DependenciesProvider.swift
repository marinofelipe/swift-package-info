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
    package: PackageWrapper,
    verbose: Bool
  ) -> Result<ProvidedInfo, InfoProviderError> {
    guard let product = package.products.first(where: { $0.name == swiftPackage.product }) else {
      return .failure(
        .init(
          localizedError: DependenciesProviderError.failedToMatchProduct
        )
      )
    }

    let productTargets = product.targets
    let externalDependencies = getExternalDependencies(
      forTargets: productTargets,
      package: package
    )

    return .success(
      .init(
        providerName: "Dependencies",
        providerKind: .dependencies,
        information: DependenciesInformation(dependencies: externalDependencies)
      )
    )
  }

  private static func getExternalDependencies(
    forTargets targets: [PackageWrapper.Target],
    package: PackageWrapper
  ) -> [DependenciesInformation.Dependency] {
    let externalDependencies = targets
      .map(\.productDependencies)
      .reduce(
        [],
        +
      )

    let transitiveExternalDependencies = targets
      .map(\.allTransitiveProductDependencies)
      .reduce([], +)

    let allExternalDependencies = externalDependencies + transitiveExternalDependencies

    let dependencies = allExternalDependencies.map(DependenciesInformation.Dependency.init)

    return dependencies.sorted(by: { $0.product < $1.product })
  }
}

private extension PackageWrapper.Target {
  var productDependencies: [PackageWrapper.Product] {
    dependencies.compactMap(\.product)
  }

  var targetDependencies: [PackageWrapper.Target] {
    dependencies.compactMap(\.target)
  }

  var allTransitiveProductDependencies: [PackageWrapper.Product] {
    mapTransitiveProducts(targets: targetDependencies)
  }

  private func mapTransitiveProducts(targets: [PackageWrapper.Target]) -> [PackageWrapper.Product] {
    let productDependencies = targets.map(\.dependencies)
      .reduce([], +)
      .compactMap(\.product)

    let targetDependencies = targets.map(\.targetDependencies)
      .reduce([], +)

    if targetDependencies.isEmpty == false {
      return mapTransitiveProducts(targets: targetDependencies)
    } else {
      return productDependencies
    }
  }
}

struct DependenciesInformation: Equatable, CustomConsoleMessagesConvertible {
  struct Dependency: Equatable, Encodable {
    let product: String
    let package: String
  }

  let dependencies: [Dependency]

  var messages: [ConsoleMessage] { buildConsoleMessages() }

  private func buildConsoleMessages() -> [ConsoleMessage] {
    if dependencies.isEmpty {
      return [
        .init(
          text: "No third-party dependencies :)",
          hasLineBreakAfter: false
        )
      ]
    } else {
      return dependencies.map { dependency -> [ConsoleMessage] in
        var messages: [ConsoleMessage] = [
          .init(
            text: "\(dependency.product); \(dependency.package)",
            hasLineBreakAfter: false
          ),
        ]

        let isLast = dependency == dependencies.last
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
  init(
    from dependency: PackageWrapper.Product
  ) {
    self.init(
      product: dependency.name,
      package: dependency.package ?? ""
    )
  }
}
