//
//  Console.swift
//
//  Acknowledgement: This piece of code is inspired by Raycast's script-commands repository:
//  https://github.com/raycast/script-commands/blob/master/Tools/Toolkit/Sources/ToolkitLibrary/Core/Console.swift
//
//  Created by Marino Felipe on 28.12.20.
//

import TSCBasic

// MARK: - ConsoleColor - Wrapper

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

// MARK: - ConsoleMessage

public struct ConsoleMessage: Equatable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    public let text: String //FIXME: Remove public
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

// MARK: - CustomConsoleMessageConvertible

public protocol CustomConsoleMessageConvertible {
    /// A console message representation.
    var message: ConsoleMessage { get }
}

public protocol CustomConsoleMessagesConvertible {
    /// A console message representation that is split into and composed by multiple messages.
    var messages: [ConsoleMessage] { get }
}

// MARK: - Console

public final class Console {
    private var isOutputColored: Bool
    private let terminalController: TerminalController?

    let animation = MultiLineNinjaProgressAnimation(stream: stdoutStream)

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
}

// MARK: - Private

private extension Console {
    func write(
        message: String,
        color: TerminalController.Color,
        bold: Bool,
        addLineBreakAfter: Bool
    ) {
        terminalController?.write(message, inColor: color, bold: bold)
        if addLineBreakAfter { self.lineBreak() }
    }
}

#if DEBUG
extension Console {
    public static let `default` = Console(isOutputColored: true)
}
#else
extension Console {
    public static let `default` = Console(isOutputColored: true)
}
#endif

import TSCUtility

public extension Console {
//    let animation = MultiLineNinjaProgressAnimation(stream: stdoutStream)

    func showLoading(
//        progress: CFloat
        text: String = "Operation in Progress..."
    ) {
//        let animation = MultiLineNinjaProgressAnimation(stream: stdoutStream)

        animation.update(step: 0, total: 1, text: text)
    }

    func updateLoading() {
        animation.update(step: 1, total: 1, text: "Progress completed!")
    }

    func completeLoading() {
        animation.complete(success: true)
    }
}
