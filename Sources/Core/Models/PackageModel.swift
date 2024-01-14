//  Copyright (c) 2024 Felipe Marino
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

import PackageModel

/// A wrapper over SwiftPM library Package type.
/// `Equatable` and `easily testable`
public struct PackageWrapper: Equatable {
  public struct Product: Equatable {
    public let name: String
    public let package: String?
    public let isDynamicLibrary: Bool?
    public let targets: [Target]
  }

  public struct Target: Equatable {
    public enum Dependency: Equatable {
      case target(Target)
      case product(Product)

      public var target: Target? {
        switch self {
        case let .target(target):
          return target
        case .product:
          return nil
        }
      }

      public var product: Product? {
        switch self {
        case .target:
          return nil
        case let .product(product):
          return product
        }
      }
    }

    public let name: String
    public let dependencies: [Dependency]
  }

  public struct Platform: Equatable {
    public let platformName: String
    public let version: String
  }

  public let products: [Product]
  public let platforms: [Platform]
  public let targets: [Target]
}

extension PackageWrapper {
  public init(from package: Package) {
    products = package.products.map(Product.init(from:))
    platforms = package.manifest.platforms.map(Platform.init(from:))
    targets = package.targets.map(Target.init(from:))
  }
}

// MARK: - Mappers

extension PackageWrapper.Target {
  init(from target: PackageModel.Target) {
    name = target.name
    dependencies = target.dependencies.map(Dependency.init(from:))
  }
}

extension PackageWrapper.Target.Dependency {
  init(from dependency: PackageModel.Target.Dependency) {
    switch dependency {
      case let .target(target, _):
      self = .target(PackageWrapper.Target(from: target))
      case let .product(product, _):
      self = .product(PackageWrapper.Product(from: product))
    }
  }
}

extension PackageWrapper.Product {
  init(from product: PackageModel.Product) {
    name = product.name
    package = nil
    isDynamicLibrary = product.isDynamicLibrary
    targets = product.targets.map(PackageWrapper.Target.init(from:))
  }
}

extension PackageWrapper.Product {
  init(from product: PackageModel.Target.ProductReference) {
    name = product.name
    package = product.package
    isDynamicLibrary = nil
    targets = []
  }
}

extension PackageWrapper.Platform {
  init(from platformDescription: PackageModel.PlatformDescription) {
    platformName = platformDescription.platformName
    version = platformDescription.version
  }
}

// MARK: - PackageModel Extensions

private extension Product {
  var isDynamicLibrary: Bool {
    switch type {
      case .library(.dynamic):
        return true
      default:
        return false
    }
  }
}
