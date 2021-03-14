//
//  InfoProvider.swift
//  
//
//  Created by Marino Felipe on 02.01.21.
//

import Foundation

public struct InfoProviderError: Error, CustomConsoleMessageConvertible {
    public let message: ConsoleMessage

    public init(
        localizedError: LocalizedError,
        customConsoleMessage: ConsoleMessage? = nil
    ) {
        self.message = customConsoleMessage ?? .init(
            text: localizedError.errorDescription ?? "",
            color: .red,
            isBold: true,
            hasLineBreakAfter: true
        )
    }
}

public typealias InfoProvider = (
    _ swiftPackage: SwiftPackage,
    _ packageContent: PackageContent,
    _ verbose: Bool
) -> Result<ProvidedInfo, InfoProviderError>

public struct ProvidedInfo: Encodable, CustomConsoleMessagesConvertible {
    public let providerName: String
    public var messages: [ConsoleMessage] {
        informationMessagesConvertible.messages
    }

    private let informationEncoder: (Encoder) throws -> Void
    private let informationMessagesConvertible: CustomConsoleMessagesConvertible

    public init<T>(
        providerName: String,
        information: T
    ) where T: Encodable, T: CustomConsoleMessagesConvertible {
        self.providerName = providerName
        self.informationMessagesConvertible = information
        self.informationEncoder = { encoder in
            var container = encoder.singleValueContainer()
            try container.encode(information)
        }
    }

    public func encode(to encoder: Encoder) throws {
        try informationEncoder(encoder)
    }
}
