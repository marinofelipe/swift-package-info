//
//  XCTest+TestSupport.swift
//  
//
//  Created by Marino Felipe on 23.01.21.
//

import XCTest

public extension XCTestCase {
    func dataFromJSON(named name: String, bundle: Bundle) throws -> Data {
        let jsonData = try bundle.url(forResource: name, withExtension: "json")
            .flatMap { try Data(contentsOf: $0) }
        return try XCTUnwrap(jsonData)
    }
}
