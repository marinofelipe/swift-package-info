//
//  Fixture+SwiftPackage.swift
//  
//
//  Created by Marino Felipe on 07.03.21.
//

import Foundation

import Core

public extension Fixture {
    static func makeSwiftPackage(
        url: URL = URL(string: "https://www.apple.com")!,
        isLocal: Bool = false,
        product: String = "Some"
    ) -> SwiftPackage {
        .init(
            url: url,
            isLocal: isLocal,
            version: "1.0.0",
            product: product
        )
    }
}
