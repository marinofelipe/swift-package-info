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

import TSCBasic
import Core

public final class Report: Reporting {
  let swiftPackage: SwiftPackage
  private let console: Console

  public init(
    swiftPackage: SwiftPackage,
    console: Console
  ) {
    self.swiftPackage = swiftPackage
    self.console = console
  }

  public func generate(
    for providedInfo: ProvidedInfo,
    format: ReportFormat
  ) async throws {
    try await generate(
      for: [providedInfo],
      format: format
    )
  }

  public func generate(
    for providedInfos: [ProvidedInfo],
    format: ReportFormat
  ) async throws {
    let reportGenerator = await format.makeReportGenerator(console: console)
    try await reportGenerator(
      swiftPackage,
      providedInfos
    )
  }
}

// MARK: - SwiftPackage: CustomConsoleMessageConvertible

extension SwiftPackage: @retroactive CustomConsoleMessageConvertible {
  public var message: ConsoleMessage {
    .init(
      text: "\(product), \(versionOrRevision)",
      color: .cyan,
      isBold: false,
      hasLineBreakAfter: false
    )
  }

  private var versionOrRevision: String {
    switch resolution {
    case let .revision(revision):
      return revision
    case let .version(tag):
      return tag
    }
  }
}
