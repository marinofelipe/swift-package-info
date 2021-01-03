//
//  SwiftPackage.swift
//  
//
//  Created by Marino Felipe on 30.12.20.
//

import struct Foundation.URL

public struct SwiftPackage: Equatable, CustomStringConvertible {
    public let repositoryURL: URL
    public let version: String
    public let product: String

    public init(
        repositoryURL: URL,
        version: String,
        product: String
    ) {
        self.repositoryURL = repositoryURL
        self.version = version
        self.product = product
    }

    public var description: String {
        """
        Repository URL: \(repositoryURL)
        Version: \(version)
        Product: \(product)
        """
    }
}
