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
    ) {
        generate(
            for: [providedInfo],
            format: format
        )
    }

    public func generate(
        for providedInfos: [ProvidedInfo],
        format: ReportFormat
    ) {
        let reportGenerator = format.makeReportGenerator()
        reportGenerator(
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

// TODO:
// Define argument and values for report format

// Inside Reports //
// There's a Encodable wrapper structure for the final json and logic to combine messages into a console report

// For Reports thingys
//extension Encodable {
//  func asDictionary(
//    encoder: JSONEncoder = .init()
//  ) throws -> [String: Any] {
//    let data = try encoder.encode(self)
//    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
//      throw NSError()
//    }
//    return dictionary
//  }
//}
