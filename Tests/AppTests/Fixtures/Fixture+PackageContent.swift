//
//  Fixture+PackageContent.swift
//
//
//  Created by Marino Felipe on 07.03.21.
//

import Foundation
import CoreTestSupport

@testable import Core

public extension Fixture {
    static func makePackageContent(
        platforms: [PackageContent.Platform] = [],
        products: [PackageContent.Product] = [],
        dependencies: [PackageContent.Dependency] = [],
        targets: [PackageContent.Target] = [],
        swiftLanguageVersions: [String]? = []
    ) -> PackageContent {
        .init(
            name: "Package",
            platforms: platforms,
            products: products,
            dependencies: dependencies,
            targets: targets,
            swiftLanguageVersions: swiftLanguageVersions
        )
    }

    static func makePackageContentPlatform(
        platformName: String = "ios",
        version: String = "13.5"
    ) -> PackageContent.Platform {
        .init(
            platformName: platformName,
            version: version
        )
    }
}
