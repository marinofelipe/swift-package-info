//
//  Array+Core.swift
//  
//
//  Created by Marino Felipe on 10.01.21.
//

import Foundation

public extension Array {
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else { return nil }

        return self[index]
    }
}
