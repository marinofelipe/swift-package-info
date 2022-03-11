//  Copyright (c) 2022 Felipe Marino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
