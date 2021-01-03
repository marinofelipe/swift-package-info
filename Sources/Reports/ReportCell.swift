//
//  ReportCell.swift
//  
//
//  Created by Marino Felipe on 02.01.21.
//

import Core

struct ReportCell: Equatable {
    let messages: [ConsoleMessage]
    let size: Int
    let textSize: Int

    init(messages: [ConsoleMessage], customSize: Int? = nil) {
        self.messages = messages

        let textSize = messages
            .map(\.text.count)
            .reduce(0, +)
        self.size = customSize ?? textSize
        self.textSize = textSize
    }

    static func makeColumnHeaderCell(title: String, size: Int) -> Self {
        .init(
            messages: [
                .init(
                    text: title,
                    color: .noColor,
                    isBold: false,
                    hasLineBreakAfter: false
                )
            ],
            customSize: size
        )
    }

    static func makeProviderTitleCell(named name: String, size: Int) -> Self {
        .init(
            messages: [
                .init(
                    text: name,
                    color: .yellow,
                    isBold: true,
                    hasLineBreakAfter: false
                )
            ],
            customSize: size
        )
    }

    static func makeForProvidedInfo(providedInfo: ProvidedInfo, size: Int) -> Self {
        .init(
            messages: providedInfo.messages,
            customSize: size
        )
    }

    static func makeTitleCell(text: String) -> Self {
        .init(
            messages: [
                .init(
                    text: text,
                    color: .cyan,
                    isBold: true,
                    hasLineBreakAfter: false
                )
            ]
        )
    }
}
