//  Copyright (c) 2022 Felipe Marino
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import XCTest
import CoreTestSupport

@testable import Core
@testable import Reports

@MainActor
final class JSONDumpReportGeneratorTests: XCTestCase {
  func testRenderDumpWithOneKindOfProvidedInfoOnly() async throws {
    let terminalControllerMock = TerminalControllerMock()
    let progressAnimationMock = ProgressAnimationMock()

    Console.default = Console(
      isOutputColored: false,
      terminalController: terminalControllerMock,
      progressAnimation: progressAnimationMock
    )

    let sut = JSONDumpReportGenerator(console: .default)

    try sut.renderDump(
      for: Fixture.makePackageDefinition(),
      providedInfos: [
        ProvidedInfo.init(
          providerName: "Name",
          providerKind: .binarySize,
          information: Fixture.makeProvidedInfoInformation()
        )
      ]
    )

    await Task.yield()
    await Task.yield()

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

  func testRenderDumpWithAllProvidedInfoKinds() async throws {
    let terminalControllerMock = TerminalControllerMock()
    let progressAnimationMock = ProgressAnimationMock()

    Console.default = Console(
      isOutputColored: false,
      terminalController: terminalControllerMock,
      progressAnimation: progressAnimationMock
    )

    let sut = JSONDumpReportGenerator(console: .default)

    try sut.renderDump(
      for: Fixture.makePackageDefinition(),
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

    await Task.yield()
    await Task.yield()

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
