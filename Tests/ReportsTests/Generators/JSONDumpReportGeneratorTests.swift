//
//  JSONDumpReportGeneratorTests.swift
//  
//
//  Created by Marino Felipe on 21.03.21.
//

import XCTest
import CoreTestSupport

@testable import Core
@testable import Reports

final class JSONDumpReportGeneratorTests: XCTestCase {
    func testRenderDumpWithOneKindOfProvidedInfoOnly() throws {
        let terminalControllerMock = TerminalControllerMock()
        let progressAnimationMock = ProgressAnimationMock()

        Console.default = Console(
            isOutputColored: false,
            terminalController: terminalControllerMock,
            progressAnimation: progressAnimationMock
        )

        let sut = JSONDumpReportGenerator(console: .default)

        try sut.renderDump(
            for: Fixture.makeSwiftPackage(),
            providedInfos: [
                ProvidedInfo.init(
                    providerName: "Name",
                    providerKind: .binarySize,
                    information: Fixture.makeProvidedInfoInformation()
                )
            ]
        )

        XCTAssertEqual(progressAnimationMock.completeCallsCount, 0)
        XCTAssertEqual(progressAnimationMock.clearCallsCount, 0)
        XCTAssertEqual(progressAnimationMock.updateCallsCount, 0)

        XCTAssertEqual(terminalControllerMock.writeCallsCount, 1)
        XCTAssertEqual(terminalControllerMock.endLineCallsCount, 1)

        XCTAssertEqual(
            terminalControllerMock.writeStrings,
            [
                #"""
                {
                  "binarySize" : {
                    "name" : "name",
                    "value" : 10
                  }
                }
                """#
            ]
        )

        XCTAssertEqual(
            terminalControllerMock.writeColors,
            [
                .noColor
            ]
        )
        XCTAssertEqual(
            terminalControllerMock.writeBolds,
            [
                false
            ]
        )
    }

    func testRenderDumpWithAllProvidedInfoKinds() throws {
        let terminalControllerMock = TerminalControllerMock()
        let progressAnimationMock = ProgressAnimationMock()

        Console.default = Console(
            isOutputColored: false,
            terminalController: terminalControllerMock,
            progressAnimation: progressAnimationMock
        )

        let sut = JSONDumpReportGenerator(console: .default)

        try sut.renderDump(
            for: Fixture.makeSwiftPackage(),
            providedInfos: [
                ProvidedInfo.init(
                    providerName: "Name",
                    providerKind: .binarySize,
                    information: Fixture.makeProvidedInfoInformation()
                ),
                ProvidedInfo.init(
                    providerName: "Other",
                    providerKind: .dependencies,
                    information: Fixture.makeProvidedInfoInformation(
                        name: "other",
                        value: 9999
                    )
                ),
                ProvidedInfo.init(
                    providerName: "Yet another",
                    providerKind: .platforms,
                    information: Fixture.makeProvidedInfoInformation(
                        name: "yet another",
                        value: 17
                    )
                )
            ]
        )

        XCTAssertEqual(progressAnimationMock.completeCallsCount, 0)
        XCTAssertEqual(progressAnimationMock.clearCallsCount, 0)
        XCTAssertEqual(progressAnimationMock.updateCallsCount, 0)

        XCTAssertEqual(terminalControllerMock.writeCallsCount, 1)
        XCTAssertEqual(terminalControllerMock.endLineCallsCount, 1)

        XCTAssertEqual(
            terminalControllerMock.writeStrings,
            [
                #"""
                {
                  "binarySize" : {
                    "name" : "name",
                    "value" : 10
                  },
                  "dependencies" : {
                    "name" : "other",
                    "value" : 9999
                  },
                  "platforms" : {
                    "name" : "yet another",
                    "value" : 17
                  }
                }
                """#
            ]
        )

        XCTAssertEqual(
            terminalControllerMock.writeColors,
            [
                .noColor
            ]
        )
        XCTAssertEqual(
            terminalControllerMock.writeBolds,
            [
                false
            ]
        )
    }
}
