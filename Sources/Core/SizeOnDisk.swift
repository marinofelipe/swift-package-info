//
//  SizeOnDisk.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

struct SizeOnDisk: Equatable {
    let amount: Int
    let formatted: String

    static let empty: SizeOnDisk = .init(amount: 0, formatted: "0.0")
}
