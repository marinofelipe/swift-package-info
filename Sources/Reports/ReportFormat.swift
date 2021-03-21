//
//  ReportFormat.swift
//  
//
//  Created by Marino Felipe on 20.03.21.
//

import Core

public enum ReportFormat: String, CaseIterable {
    case consoleMessage
    case jsonDump
}

extension ReportFormat {
    func makeReportGenerator(console: Console = .default) -> ReportGenerating {
        switch self {
        case .consoleMessage:
            return ConsoleReportGenerator(console: console).renderReport
        case .jsonDump:
            return JSONDumpReportGenerator(console: console).renderDump
        }
    }
}
