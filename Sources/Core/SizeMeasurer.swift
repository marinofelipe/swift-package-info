//
//  Measure.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import Foundation

public struct SizeMeasurer {
    public private(set) var emptyAppSize: SizeOnDisk = .empty
    public private(set) var appWithDependencyAddedSize: SizeOnDisk = .empty

    private var appManager: AppManager

    public init() {
        self.init(appManager: .init())
    }

    init(appManager: AppManager = .init()) {
        self.appManager = appManager
    }

    public mutating func measureEmptyAppSize() throws {
        Console.default.lineBreakAndWrite(
            .init(
                text: "Measuring empty app size",
                color: .green,
                isBold: true
            )
        )

        appManager.generateArchive()
        emptyAppSize = try appManager.calculateBinarySize()
    }

    public mutating func measureAppSizeWithAlamofire() throws {
        Console.default.lineBreakAndWrite(
            .init(
                text: "Measuring app size with added dependency",
                color: .green,
                isBold: true
            )
        )

        try appManager.addAlamofireDependency()
        appManager.generateArchive()
        appWithDependencyAddedSize = try appManager.calculateBinarySize()
    }
}
