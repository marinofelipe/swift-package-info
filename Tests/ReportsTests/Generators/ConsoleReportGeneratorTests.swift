//
//  ConsoleReportGeneratorTests.swift
//
//
//  Created by Marino Felipe on 14.03.21.
//

import XCTest
import CoreTestSupport

@testable import Core
@testable import Reports

final class ConsoleReportGeneratorTests: XCTestCase {
    func testRenderReport() {
        let terminalControllerMock = TerminalControllerMock()
        let progressAnimationMock = ProgressAnimationMock()

        Console.default = Console(
            isOutputColored: false,
            terminalController: terminalControllerMock,
            progressAnimation: progressAnimationMock
        )

        let sut = ConsoleReportGenerator(
            console: .default
        )

        sut.renderReport(
            for: Fixture.makeSwiftPackage(),
            providedInfos: [
                ProvidedInfo.init(
                    providerName: "Name",
                    information: Fixture.makeProvidedInfoInformation()
                )
            ]
        )

        XCTAssertEqual(progressAnimationMock.completeCallsCount, 0)
        XCTAssertEqual(progressAnimationMock.clearCallsCount, 0)
        XCTAssertEqual(progressAnimationMock.updateCallsCount, 0)

        XCTAssertEqual(terminalControllerMock.writeCallsCount, 39)
        XCTAssertEqual(terminalControllerMock.endLineCallsCount, 13)

        XCTAssertEqual(
            terminalControllerMock.writeStrings,
            [
                "+----------------------------+",
                "|",
                "     ",
                "Swift Package Info",
                "     ",
                "|",
                "|",
                "                            ",
                "|",
                "|",
                "         ",
                "some, 1.0.0",
                "        ",
                "|",
                "+----------+-----------------+",
                "|",
                " ",
                "Provider",
                " ",
                "|",
                " ",
                "Results",
                "         ",
                "|",
                "+----------+-----------------+",
                "|",
                " ",
                "Name",
                "     ",
                "|",
                " ",
                "name",
                "Value is 10",
                " ",
                "|",
                "+----------+-----------------+",
                "> Total of ",
                "1",
                " provider used."
            ]
        )

        XCTAssertEqual(
            terminalControllerMock.writeColors.count,
            39
        )
        XCTAssertEqual(
            Set(terminalControllerMock.writeColors),
            Set([.noColor])
        )
        XCTAssertEqual(
            terminalControllerMock.writeBolds,
            [
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                true,
                false
            ]
        )
    }
}
