//
//  Console.swift
//
//  Acknowledgement: This piece of code is inspired by Raycast's script-commands repository:
//  https://github.com/unnamedd/script-commands/blob/Toolkit%2FImprovements/Tools/Toolkit/Sources/ToolkitLibrary/Core/Console.swift
//
//  Created by Marino Felipe on 28.12.20.
//

import TSCBasic

public enum ConsoleColor {
    case noColor
    case red
    case green
    case yellow
    case cyan
    case white
    case black
    case grey
}

private extension ConsoleColor {
    var terminalColor: TerminalController.Color {
        switch self {
            case .black: return .black
            case .cyan: return .cyan
            case .green: return .green
            case .grey: return .grey
            case .noColor: return .noColor
            case .red: return .red
            case .white: return .white
            case .yellow: return .yellow
        }
    }
}

public struct ConsoleMessage: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    let text: String
    let color: ConsoleColor
    let isBold: Bool
    let hasLineBreakAfter: Bool

    public init(
        text: String,
        color: ConsoleColor,
        isBold: Bool = false,
        hasLineBreakAfter: Bool = true
    ) {
        self.text = text
        self.color = color
        self.isBold = isBold
        self.hasLineBreakAfter = hasLineBreakAfter
    }

    public init(
        text: String,
        isBold: Bool = false,
        hasLineBreakAfter: Bool = true
    ) {
        self.text = text
        self.color = .noColor
        self.isBold = isBold
        self.hasLineBreakAfter = hasLineBreakAfter
    }

    public init(stringLiteral value: String) {
        self.init(text: value, color: .noColor, isBold: false, hasLineBreakAfter: true)
    }
}

protocol CustomConsoleMessageConvertible {
    var message: ConsoleMessage { get }
}

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

    public func write(_ message: ConsoleMessage) {
        write(
            message: message.text,
            color: isOutputColored ? message.color.terminalColor : .noColor,
            bold: message.isBold,
            addLineBreakAfter: message.hasLineBreakAfter
        )
    }

    public func lineBreakAndWrite(_ message: ConsoleMessage) {
        lineBreak()
        write(
            message: message.text,
            color: isOutputColored ? message.color.terminalColor : .noColor,
            bold: message.isBold,
            addLineBreakAfter: message.hasLineBreakAfter
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
