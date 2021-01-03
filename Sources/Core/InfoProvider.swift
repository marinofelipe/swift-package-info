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
    _ verbose: Bool,
    _ completion: (Result<ProvidedInfo, InfoProviderError>) -> Void
) -> Void

public struct ProvidedInfo: Equatable, CustomConsoleMessagesConvertible {
    public let providerName: String
    public var messages: [ConsoleMessage]

    public init(providerName: String, messages: [ConsoleMessage]) {
        self.providerName = providerName
        self.messages = messages
    }
}
