//
//  Reporting.swift
//  
//
//  Created by Marino Felipe on 02.01.21.
//

import Core

protocol Reporting {
    var swiftPackage: SwiftPackage { get }

    func generate(for _: ProvidedInfo)
    func generate(for _: [ProvidedInfo])
}
