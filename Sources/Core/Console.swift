//
//  Console.swift
//
//  Acknowledgement: This piece of code is inspired by Raycast's script-commands repository:
//  https://github.com/raycast/script-commands/blob/master/Tools/Toolkit/Sources/ToolkitLibrary/Core/Console.swift
//
//  Created by Marino Felipe on 28.12.20.
//

import TSCBasic
import TSCUtility

// MARK: - ConsoleColor - Wrapper

public enum ConsoleColor {
    case noColor
    case red
    case green
    case yellow
    case cyan
    case white
    case black
    case gray
}

private extension ConsoleColor {
    var terminalColor: TerminalController.Color {
        switch self {
            case .black: return .black
            case .cyan: return .cyan
            case .green: return .green
            case .gray: return .gray
            case .noColor: return .noColor
            case .red: return .red
            case .white: return .white
            case .yellow: return .yellow
        }
    }
}

// MARK: - TerminalControlling

public protocol TerminalControlling {
    func endLine()
    func write(
        _ string: String,
        inColor _: ConsoleColor,
        bold: Bool
    )
}

extension TerminalController: TerminalControlling {
    public func write(
        _ string: String,
        inColor color: ConsoleColor,
        bold: Bool
    ) {
        write(
            string,
            inColor: color.terminalColor,
            bold: bold
        )
    }
}

final class PrintController: TerminalControlling {
    func endLine() {
        print()
    }

    func write(_ string: String, inColor _: ConsoleColor, bold: Bool) {
        print(string)
    }

}

// MARK: - ConsoleMessage

public struct ConsoleMessage: Equatable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    public let text: String
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
    private let terminalController: TerminalControlling
    private let progressAnimation: ProgressAnimationProtocol

    public init(
        isOutputColored: Bool,
        terminalController: TerminalControlling = TerminalControllerFactory.make(stream: stdoutStream),
        progressAnimation: ProgressAnimationProtocol = NinjaProgressAnimation(stream: stdoutStream)
    ) {
        self.isOutputColored = isOutputColored
        self.terminalController = terminalController
        self.progressAnimation = progressAnimation
    }

    public func write(_ message: ConsoleMessage) {
        write(
            message: message.text,
            color: isOutputColored ? message.color : .noColor,
            bold: message.isBold,
            addLineBreakAfter: message.hasLineBreakAfter
        )
    }

    public func lineBreakAndWrite(_ message: ConsoleMessage) {
        lineBreak()
        write(
            message: message.text,
            color: isOutputColored ? message.color : .noColor,
            bold: message.isBold,
            addLineBreakAfter: message.hasLineBreakAfter
        )
    }

    public func lineBreak() {
        terminalController.endLine()
    }
}

public final class TerminalControllerFactory {
    public static func make(stream: WritableByteStream = stdoutStream) -> TerminalControlling {
        if let controller = TerminalController(stream: stream) {
            return controller
        } else {
            return PrintController()
        }
    }
}

// MARK: - Loading

public extension Console {
    func showLoading(
        step: Int ,
        total: Int = 10,
        text: String
    ) {
        progressAnimation.update(
            step: step,
            total: total,
            text: text
        )
    }

    func completeLoading(success: Bool) {
        progressAnimation.complete(success: success)
    }
}

// MARK: - Private

private extension Console {
    func write(
        message: String,
        color: ConsoleColor,
        bold: Bool,
        addLineBreakAfter: Bool
    ) {
        terminalController.write(message, inColor: color, bold: bold)
        if addLineBreakAfter { self.lineBreak() }
    }
}

#if DEBUG
extension Console {
    public static var `default` = Console(isOutputColored: false)
}
#else
extension Console {
    public static let `default` = Console(isOutputColored: true)
}
#endif
