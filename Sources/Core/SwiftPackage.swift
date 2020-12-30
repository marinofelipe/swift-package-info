//
//  SwiftPackage.swift
//  
//
//  Created by Marino Felipe on 30.12.20.
//

import struct Foundation.URL

struct SwiftPackage: Equatable {
    let repositoryURL: URL
    let productName: String
    let version: String
}
