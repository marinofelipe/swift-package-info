//
//  Fixture+ProvidedInfo.swift
//  
//
//  Created by Marino Felipe on 20.03.21.
//

import Core

public extension Fixture {
    struct ProvidedInformation: Encodable, CustomConsoleMessagesConvertible {
        let name: String
        let value: Int

        public var messages: [ConsoleMessage] {
            [
                .init(
                    text: name,
                    color: .green,
                    isBold: true,
                    hasLineBreakAfter: false
                ),
                .init(
                    text: "Value is \(value)",
                    color: .noColor,
                    isBold: false,
                    hasLineBreakAfter: true
                ),
            ]
        }
    }

    static func makeProvidedInfoInformation(
        name: String = "name",
        value: Int = 10
    ) -> ProvidedInformation {
        .init(
            name: name,
            value: value
        )
    }
}
