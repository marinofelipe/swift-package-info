//
//  ReportGenerating.swift
//  
//
//  Created by Marino Felipe on 20.03.21.
//

import Core

typealias ReportGenerating = (
    _ swiftPackage: SwiftPackage,
    _ providedInfos: [ProvidedInfo]
) -> Void
