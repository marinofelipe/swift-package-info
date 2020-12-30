//
//  Console.swift
//
//  Acknowledgement: This piece of code is inspired by Raycast's script-commands repository:
//  https://github.com/unnamedd/script-commands/blob/Toolkit%2FImprovements/Tools/Toolkit/Sources/ToolkitLibrary/Core/Console.swift
//
//  Created by Marino Felipe on 28.12.20.
//

import TSCBasic

public final class Console {
    private var isOutputColored: Bool
    private let terminalController: TerminalController?

    public static let `default`: Console = .init(isOutputColored: true)

    public init(
        isOutputColored: Bool,
        terminalController: TerminalController? = TerminalController(stream: stdoutStream)
    ) {
        self.isOutputColored = isOutputColored
        self.terminalController = terminalController
    }

    public func write(
        _ message: String,
        color: TerminalController.Color,
        bold: Bool = false,
        addLineBreakAfter: Bool = true
    ) {
        write(
            message: message,
            color: isOutputColored ? color : .noColor,
            bold: bold,
            addLineBreakAfter: addLineBreakAfter
        )
    }

    public func write(
        _ message: String,
        bold: Bool = false,
        addLineBreakAfter: Bool = true
    ) {
        write(
            message: message,
            color: .noColor,
            bold: bold,
            addLineBreakAfter: addLineBreakAfter
        )
    }

    public func lineBreakAndWrite(
        _ message: String,
        color: TerminalController.Color,
        bold: Bool = false,
        addLineBreakAfter: Bool = true
    ) {
        lineBreak()
        write(
            message: message,
            color: isOutputColored ? color : .noColor,
            bold: bold,
            addLineBreakAfter: addLineBreakAfter
        )
    }

    public func lineBreakAndWrite(
        _ message: String,
        bold: Bool = false,
        addLineBreakAfter: Bool = true
    ) {
        lineBreak()
        write(
            message: message,
            color: .noColor,
            bold: bold,
            addLineBreakAfter: addLineBreakAfter
        )
    }

    public func lineBreak() {
        terminalController?.endLine()
    }

    // MARK: - Private

    private func write(
        message: String,
        color: TerminalController.Color,
        bold: Bool,
        addLineBreakAfter: Bool
    ) {
        terminalController?.write(message, inColor: color, bold: bold)
        if addLineBreakAfter { self.lineBreak() }
    }
}
