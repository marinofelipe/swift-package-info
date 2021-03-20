//
//  TerminalControllerMock.swift
//  
//
//  Created by Marino Felipe on 20.03.21.
//

import Core

public final class TerminalControllerMock: TerminalControlling {
    public private(set) var endLineCallsCount: Int = 0
    public private(set) var writeCallsCount: Int = 0
    public private(set) var writeStrings: [String] = []
    public private(set) var writeColors: [ConsoleColor] = []
    public private(set) var writeBolds: [Bool] = []

    public init() { }

    public func endLine() {
        endLineCallsCount += 1
    }

    public func write(
        _ string: String,
        inColor color: ConsoleColor,
        bold: Bool
    ) {
        writeCallsCount += 1
        writeStrings.append(string)
        writeColors.append(color)
        writeBolds.append(bold)
    }
}
