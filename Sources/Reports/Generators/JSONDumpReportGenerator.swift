//  Copyright (c) 2025 Felipe Marino
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

import Core
import Foundation

struct JSONDumpReportGenerator {
  private let console: Console
  private let encoder: JSONEncoder

  init(
    console: Console,
    encoder: JSONEncoder = .sortedAndPrettyPrinted
  ) {
    self.console = console
    self.encoder = encoder
  }

  func renderDump(
    for swiftPackage: PackageDefinition,
    providedInfos: [ProvidedInfo]
  ) throws {
    let reportData = ReportData(
      providedInfos: providedInfos
    )

    let data = try encoder.encode(reportData)
    let stringData = String(data: data, encoding: .utf8) ?? ""

    Task { @MainActor in
      console.write(
        .init(text: stringData)
      )
    }
  }
}

struct ReportData: Encodable {
  let providedInfos: [ProvidedInfo]

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: ProviderKind.self)

    if let binarySizeInfo = providedInfos.first(where: \.providerKind == .binarySize) {
      try container.encode(binarySizeInfo, forKey: .binarySize)
    }
    if let dependenciesInfo = providedInfos.first(where: \.providerKind == .dependencies) {
      try container.encode(dependenciesInfo, forKey: .dependencies)
    }
    if let platformsInfo = providedInfos.first(where: \.providerKind == .platforms) {
      try container.encode(platformsInfo, forKey: .platforms)
    }
  }
}
