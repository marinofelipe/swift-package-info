//
//  SwiftPackage.swift
//  
//
//  Created by Marino Felipe on 30.12.20.
//

import struct Foundation.URL

public struct SwiftPackage: Equatable, CustomStringConvertible {
    public let url: URL
    public let isLocal: Bool
    public var version: String
    public var product: String

    public init(
        url: URL,
        isLocal: Bool,
        version: String,
        product: String
    ) {
        self.url = url
        self.isLocal = isLocal
        self.version = version
        self.product = product
    }

    public var description: String {
        """
        \(isLocal ? "Local path" : "Repository URL"): \(url)
        Version: \(version)
        Product: \(product)
        """
    }
}

public extension SwiftPackage {
    var accountName: String {
        guard isLocal == false else { return "" }

        return url
            .pathComponents[safeIndex: url.pathComponents.count - 2] ?? ""
    }

    var repositoryName: String {
        guard isLocal == false else { return "" }

        return (url.pathComponents.last ?? "")
            .replacingOccurrences(of: ".git", with: "")
    }
}
