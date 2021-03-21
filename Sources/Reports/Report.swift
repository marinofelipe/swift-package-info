//
//  Report.swift
//
//  Acknowledgement: This piece of code is inspired by Raycast's script-commands repository:
//  https://github.com/unnamedd/script-commands/blob/Toolkit/Improvements/Tools/Toolkit/Sources/ToolkitLibrary/Core/Report/Report.swift

//  Created by Marino Felipe on 01.01.21.
//

import TSCBasic
import Core

public final class Report: Reporting {
    let swiftPackage: SwiftPackage
    private let console: Console

    public init(
        swiftPackage: SwiftPackage,
        console: Console = .default
    ) {
        self.swiftPackage = swiftPackage
        self.console = console
    }

    public func generate(
        for providedInfo: ProvidedInfo,
        format: ReportFormat
    ) throws {
        try generate(
            for: [providedInfo],
            format: format
        )
    }

    public func generate(
        for providedInfos: [ProvidedInfo],
        format: ReportFormat
    ) throws {
        let reportGenerator = format.makeReportGenerator()
        try reportGenerator(
            swiftPackage,
            providedInfos
        )
    }
}

// MARK: - SwiftPackage: CustomConsoleMessageConvertible

extension SwiftPackage: CustomConsoleMessageConvertible {
    public var message: ConsoleMessage {
        .init(
            text: "\(product), \(version)",
            color: .cyan,
            isBold: false,
            hasLineBreakAfter: false
        )
    }
}
