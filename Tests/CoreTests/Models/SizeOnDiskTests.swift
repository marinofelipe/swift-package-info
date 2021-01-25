//
//  SizeOnDiskTests.swift
//  
//
//  Created by Marino Felipe on 29.12.20.
//

import XCTest
@testable import Core

final class SizeOnDiskTests: XCTestCase {
    func testEmpty() {
        XCTAssertEqual(
            SizeOnDisk.empty,
            .init(amount: 0, formatted: "0.0")
        )
    }
}
