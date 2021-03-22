//
//  BinarySizeProviderErrorTests.swift
//
//
//  Created by Marino Felipe on 31.01.20.
//

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
