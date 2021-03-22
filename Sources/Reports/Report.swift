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
