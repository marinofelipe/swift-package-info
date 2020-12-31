//
//  TSCUtility+Run.swift
//  
//
//  Created by Marino Felipe on 31.12.20.
//

import ArgumentParser
import TSCUtility

extension TSCUtility.Version: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(string: argument)
    }

    public var defaultValueDescription: String { "1.2.12" }
}
