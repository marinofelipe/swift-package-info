//
//  Measure.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import Foundation
import Core

final class SizeMeasurer {
    private var appManager: AppManager
    private let console: Console

    public convenience init() {
        self.init(appManager: .init())
    }

    init(
        appManager: AppManager = .init(),
        console: Console = .default
    ) {
        self.appManager = appManager
        self.console = console
    }

    public func measureEmptyAppSize() throws -> SizeOnDisk {
        console.lineBreakAndWrite(
            .init(
                text: "Measuring empty app size",
                color: .green,
                isBold: true
            )
        )

        appManager.generateArchive()
        return try appManager.calculateBinarySize()
    }

    public func measureAppSize(with swiftPackage: SwiftPackage) throws -> SizeOnDisk {
        console.lineBreakAndWrite(
            .init(
                text: "Measuring app size with \(swiftPackage.product) added as dependency",
                color: .green,
                isBold: true
            )
        )

        try appManager.add(asDependency: swiftPackage)
        appManager.generateArchive()
        return try appManager.calculateBinarySize()
    }

    public func cleanup() throws {
        try appManager.cleanupTemporaryDerivedData()
        appManager.removeAppDependencies()
    }
}
