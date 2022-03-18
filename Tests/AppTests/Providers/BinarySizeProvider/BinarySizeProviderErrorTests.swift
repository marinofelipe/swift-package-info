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
@testable import App

final class BinarySizeProviderErrorTests: XCTestCase {
    func testUnableToGenerateArchiveLocalizedMessage() {
        let error = BinarySizeProviderError.unableToGenerateArchive(errorMessage: "some")
        XCTAssertEqual(
            error.localizedDescription,
            """
            Failed to measure binary size
            Step: Archiving
            Error: some
            """
        )
    }

    func testUnableToCloneEmptyAppLocalizedMessage() {
        let error = BinarySizeProviderError.unableToCloneEmptyApp(errorMessage: "some")
        XCTAssertEqual(
            error.localizedDescription,
            """
            Failed to measure binary size
            Step: Cloning empty app
            Error: some
            """
        )
    }

    func testUnableToGetBinarySizeOnDiskLocalizedMessage() {
        let error = BinarySizeProviderError.unableToGetBinarySizeOnDisk(underlyingError: FakeError() as NSError)
        XCTAssertEqual(
            error.localizedDescription,
            """
            Failed to measure binary size
            Step: Reading binary size
            Error: Failed to read binary size from archive. Details: some
            """
        )
    }

    func testUnableToRetrieveAppProjectLocalizedMessage() {
        let error = BinarySizeProviderError.unableToRetrieveAppProject(atPath: "path")
        XCTAssertEqual(
            error.localizedDescription,
            """
            Failed to measure binary size
            Step: Read measurement app project
            Error: Failed to get MeasurementApp project from XcodeProj at path: path
            """
        )
    }

    func testUnexpectedErrorLocalizedMessageWhenVerboseTrue() {
        let error = BinarySizeProviderError.unexpectedError(
            underlyingError: URLError(.badURL) as NSError,
            isVerbose: true
        )
        XCTAssertEqual(
            error.localizedDescription,
            """
            Failed to measure binary size
            Step: Undefined
            Error: Unexpected failure. Error Domain=NSURLErrorDomain Code=-1000 "(null)".

            """
        )
    }

    func testUnexpectedErrorLocalizedMessageWhenVerboseFalse() {
        let error = BinarySizeProviderError.unexpectedError(
            underlyingError: URLError(.badURL) as NSError,
            isVerbose: false
        )
        XCTAssertEqual(
            error.localizedDescription,
            """
            Failed to measure binary size
            Step: Undefined
            Error: Unexpected failure. Error Domain=NSURLErrorDomain Code=-1000 "(null)".
            Please run with --verbose enabled for more details.
            """
        )
    }
}

private struct FakeError: LocalizedError {
    let errorDescription: String? = "some"
}
