//
//  Printer.swift
//  
//
//  Created by Marino Felipe on 28.12.20.
//

struct Printer {
    static let header = """
    ------------------------------------------------------------------------------
    """

    static func print(_ content: String) {
        Swift.print(Self.header)
        Swift.print(content)
        Swift.print(Self.header)
    }
}
