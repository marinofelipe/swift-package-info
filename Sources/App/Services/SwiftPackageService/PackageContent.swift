//
//  PackageContent.swift
//  
//
//  Created by Marino Felipe on 10.01.21.
//

public struct PackageContent: Decodable, Equatable {
    public struct Product: Decodable, Equatable {
        public let name: String
    }

    public let name: String
    public let products: [Product]
}
