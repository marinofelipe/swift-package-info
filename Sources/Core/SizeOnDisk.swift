//
//  SizeOnDisk.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

public struct SizeOnDisk: Equatable {
    public let amount: Int
    public let formatted: String

    public static let empty: SizeOnDisk = .init(amount: 0, formatted: "0.0")
}
