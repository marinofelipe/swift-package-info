//  Copyright (c) 2025 Felipe Marino
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

internal import Foundation
internal import Core

protocol SizeMeasuring {
  func binarySize(
    for swiftPackage: PackageDefinition,
    isDynamic: Bool
  ) async throws -> SizeOnDisk
}

final class SizeMeasurer: SizeMeasuring {
  private var appManager: AppManager
  private let console: Console
  private let verbose: Bool

  public convenience init(verbose: Bool, xcconfig: URL?) async {
    await self.init(
      appManager: .init(
        console: .default,
        xcconfig: xcconfig,
        verbose: verbose
      ),
      console: .default,
      verbose: verbose
    )
  }

  init(
    appManager: AppManager,
    console: Console,
    verbose: Bool
  ) async {
    self.appManager = appManager
    self.console = console
    self.verbose = verbose
  }

  private static let stepsCount = 7
  private var currentStep = 1
  private static let second: Double = 1_000_000

  public func binarySize(
    for swiftPackage: PackageDefinition,
    isDynamic: Bool
  ) async throws -> SizeOnDisk {
    defer { try? appManager.cleanUp() }

    console.lineBreak()

    let emptyAppSize = try await measureEmptyAppSize()
    let appSizeWithDependencyAdded = try await measureAppSize(
      with: swiftPackage,
      isDynamic: isDynamic
    )

    completeLoading()
    let increasedSize = appSizeWithDependencyAdded - emptyAppSize

    return increasedSize
  }
}

// MARK: - Private

private extension SizeMeasurer {
  func measureEmptyAppSize() async throws -> SizeOnDisk {
    if verbose == false {
      showOrUpdateLoading(withText: "Cleaning up empty app directory...")
    }
    try appManager.cleanUp()

    if verbose {
      console.lineBreakAndWrite("Cloning empty app")
    } else {
      showOrUpdateLoading(withText: "Cloning empty app...")
    }
    try await appManager.cloneEmptyApp()

    if verbose {
      console.lineBreakAndWrite(
        .init(
          text: "Measuring empty app size",
          color: .green,
          isBold: true
        )
      )
    }

    if verbose == false {
      showOrUpdateLoading(withText: "Generating archive for empty app...")
    }
    try await appManager.generateArchive()

    if verbose == false {
      showOrUpdateLoading(withText: "Calculating binary size...")
    }
    return try await appManager.calculateBinarySize()
  }

  func measureAppSize(
    with swiftPackage: PackageDefinition,
    isDynamic: Bool
  ) async throws -> SizeOnDisk {
    if verbose {
      console.lineBreakAndWrite(
        .init(
          text: "Measuring app size with \(swiftPackage.product) added as dependency",
          color: .green,
          isBold: true
        )
      )
    }

    if verbose == false {
      showOrUpdateLoading(withText: "Adding \(swiftPackage.product) as dependency...")
    }
    try appManager.add(
      asDependency: swiftPackage,
      isDynamic: isDynamic
    )

    if verbose == false {
      showOrUpdateLoading(withText: "Generating archive for updated app...")
    }
    try await appManager.generateArchive()

    if verbose == false {
      showOrUpdateLoading(withText: "Calculating updated binary size...")
    }
    return try await appManager.calculateBinarySize()
  }

  func showOrUpdateLoading(withText text: String) {
    usleep(UInt32(Self.second * 0.5))
    console.showLoading(step: currentStep, total: Self.stepsCount, text: text)
    currentStep += 1
  }

  func completeLoading() {
    console.completeLoading(success: true)
    currentStep = 0
  }
}
