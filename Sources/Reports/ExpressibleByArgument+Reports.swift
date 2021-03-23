//
//  ExpressibleByArgument+Reports.swift
//  
//
//  Created by Marino Felipe on 21.03.21.
//

import ArgumentParser

extension ReportFormat: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument)
    }

    public var defaultValueDescription: String {
        ReportFormat.consoleMessage.rawValue
    }

    static public var allValueStrings: [String] {
        ReportFormat.allCases.map(\.rawValue)
    }
}
