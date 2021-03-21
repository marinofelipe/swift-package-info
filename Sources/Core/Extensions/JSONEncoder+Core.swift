//
//  JSONEncoder+Core.swift
//  
//
//  Created by Marino Felipe on 20.03.21.
//

import Foundation

public extension JSONEncoder {
    static let sortedAndPrettyPrinted: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return encoder
    }()
}
