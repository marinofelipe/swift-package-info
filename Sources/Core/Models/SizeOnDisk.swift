//
//  SizeOnDisk.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

public struct SizeOnDisk: Equatable, CustomStringConvertible, CustomConsoleMessageConvertible {
    public let amount: Int
    public let formatted: String

    public static let empty: SizeOnDisk = .init(amount: 0, formatted: "0.0")

    public var description: String {
        "Size on disk: \(formatted)"
    }

    public var message: ConsoleMessage {
        .init(
            text: description,
            color: .yellow,
            isBold: false
        )
    }
}
