//
//  ExpressibleByArgument+Core.swift
//  
//
//  Created by Marino Felipe on 21.03.21.
//

import ArgumentParser
import Foundation

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(string: argument)
    }
}
