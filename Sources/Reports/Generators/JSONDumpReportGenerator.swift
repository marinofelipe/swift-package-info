//
//  JSONDumpReportGenerator.swift
//  
//
//  Created by Marino Felipe on 20.03.21.
//

import Core
import Foundation

struct JSONDumpReportGenerator {
    private let console: Console
    private let encoder: JSONEncoder

    init(
        console: Console = .default,
        encoder: JSONEncoder = .sortedAndPrettyPrinted
    ) {
        self.console = console
        self.encoder = encoder
    }

    func renderDump(
        for swiftPackage: SwiftPackage,
        providedInfos: [ProvidedInfo]
    ) throws {
        let reportData = ReportData(
            providedInfos: providedInfos
        )

        let data = try encoder.encode(reportData)
        let stringData = String(data: data, encoding: .utf8) ?? ""

        console.write(
            .init(text: stringData)
        )
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
