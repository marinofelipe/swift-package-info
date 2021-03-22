//
//  SizeOnDisk.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import Foundation

public struct SizeOnDisk: Equatable {
    /// Literal size quantity, in `Kilobytes`
    public let amount: Int
    public let formatted: String

    public init(
        amount: Int,
        formatted: String
    ) {
        self.amount = amount
        self.formatted = formatted
    }

    public static let empty: SizeOnDisk = .init(
        amount: 0,
        formatted: "0.0"
    )
}

extension SizeOnDisk: CustomStringConvertible {
    public var description: String {
        "Size on disk: \(formatted)"
    }
}

extension SizeOnDisk: CustomConsoleMessageConvertible {
    public var message: ConsoleMessage {
        .init(
            text: description,
            color: .yellow,
            isBold: false
        )
    }
}

extension SizeOnDisk: AdditiveArithmetic {
    public static var zero: SizeOnDisk = .empty

    public static func - (lhs: SizeOnDisk, rhs: SizeOnDisk) -> SizeOnDisk {
        let finalAmount = lhs.amount - rhs.amount

        return .init(
            amount: finalAmount,
            formatted: URL.fileByteCountFormatter.string(
                for: finalAmount
            ) ?? ""
        )
    }

    public static func + (lhs: SizeOnDisk, rhs: SizeOnDisk) -> SizeOnDisk {
        let finalAmount = lhs.amount + rhs.amount

        return .init(
            amount: finalAmount,
            formatted: URL.fileByteCountFormatter.string(
                for: finalAmount
            ) ?? ""
        )
    }
}
