//
//  KeyPath+Core.swift
//  
//
//  Created by Marino Felipe on 10.01.21.
//

public func ==<T, V: Equatable>(lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    return { $0[keyPath: lhs] == rhs }
}
