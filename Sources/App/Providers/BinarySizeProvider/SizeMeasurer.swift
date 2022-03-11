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

import Foundation
import Core

typealias SizeMeasuring = (
    _ swiftPackage: SwiftPackage,
    _ isDynamic: Bool
) throws -> SizeOnDisk

final class SizeMeasurer {
    private var appManager: AppManager
    private let console: Console
    private let verbose: Bool

    public convenience init(verbose: Bool) {
        self.init(appManager: .init(verbose: verbose), verbose: verbose)
    }

    init(
        appManager: AppManager = .init(verbose: true),
        console: Console = .default,
        verbose: Bool
    ) {
        self.appManager = appManager
        self.console = console
        self.verbose = verbose
    }

    private static let stepsCount = 7
    private var currentStep = 1
    private static let second: Double = 1_000_000

    deinit {
        try? appManager.cleanUp()
    }

    public func binarySize(
        for swiftPackage: SwiftPackage,
        isDynamic: Bool
    ) throws -> SizeOnDisk {
        console.lineBreak()

        let emptyAppSize = try measureEmptyAppSize()
        let appSizeWithDependencyAdded = try measureAppSize(
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
    func measureEmptyAppSize() throws -> SizeOnDisk {
        if verbose == false { showOrUpdateLoading(withText: "Cleaning up empty app directory...") }
        try appManager.cleanUp()

        if verbose {
            console.lineBreakAndWrite("Cloning empty app")
        } else {
            showOrUpdateLoading(withText: "Cloning empty app...")
        }
        try appManager.cloneEmptyApp()

        if verbose {
            console.lineBreakAndWrite(
                .init(
                    text: "Measuring empty app size",
                    color: .green,
                    isBold: true
                )
            )
        }

        if verbose == false { showOrUpdateLoading(withText: "Generating archive for empty app...") }
        try appManager.generateArchive()
        if verbose == false { showOrUpdateLoading(withText: "Calculating binary size...") }
        return try appManager.calculateBinarySize()
    }

    func measureAppSize(
        with swiftPackage: SwiftPackage,
        isDynamic: Bool
    ) throws -> SizeOnDisk {
        if verbose {
            console.lineBreakAndWrite(
                .init(
                    text: "Measuring app size with \(swiftPackage.product) added as dependency",
                    color: .green,
                    isBold: true
                )
            )
        }

        if verbose == false { showOrUpdateLoading(withText: "Adding \(swiftPackage.product) as dependency...") }
        try appManager.add(
            asDependency: swiftPackage,
            isDynamic: isDynamic
        )
        if verbose == false { showOrUpdateLoading(withText: "Generating archive for updated app...") }
        try appManager.generateArchive()
        if verbose == false { showOrUpdateLoading(withText: "Calculating updated binary size...") }
        return try appManager.calculateBinarySize()
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
