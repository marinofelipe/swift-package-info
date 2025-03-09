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
final class ConsoleReportGeneratorTests: XCTestCase {
  func testRenderReport() throws {
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
      for: try Fixture.makeSwiftPackage(),
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
        "Some, 1.0.0",
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
