//
//  PlatformsProvider.swift
//  
//
//  Created by Marino Felipe on 24.01.21.
//

import Core

public struct PlatformsProvider {
    public static func fetchInformation(
        for swiftPackage: SwiftPackage,
        packageContent: PackageContent,
        verbose: Bool
    ) -> Result<ProvidedInfo, InfoProviderError> {
        .success(
            .init(
                providerName: "Platforms",
                information: PlatformsInformation(
                    platforms: packageContent.platforms
                )
            )
        )
    }
}

struct PlatformsInformation: Equatable, Encodable, CustomConsoleMessagesConvertible {
    let platforms: [PackageContent.Platform]
    let iOS: String?
    let macOS: String?
    let tvOS: String?
    let watchOS: String?

    var messages: [ConsoleMessage] { buildConsoleMessages() }

    init(platforms: [PackageContent.Platform]) {
        self.platforms = platforms
        self.iOS = platforms.iOSVersion
        self.macOS = platforms.macOSVersion
        self.tvOS = platforms.tvOSVersion
        self.watchOS = platforms.watchOSVersion
    }

    private enum CodingKeys: String, CodingKey {
        case iOS, macOS, tvOS, watchOS
    }

    private func buildConsoleMessages() -> [ConsoleMessage] {
        if platforms.isEmpty {
            return [
                .init(
                    text: "System default",
                    hasLineBreakAfter: false
                )
            ]
        } else {
            return platforms
                .map { platform -> [ConsoleMessage] in
                    var messages = [
                        ConsoleMessage(
                            text: "\(platform.platformName) from v. \(platform.version)",
                            isBold: true,
                            hasLineBreakAfter: false
                        )
                    ]

                    let isLastPlatform = platform == platforms.last
                    if isLastPlatform == false {
                        messages.append(
                            .init(
                                text: " | ",
                                hasLineBreakAfter: false
                            )
                        )
                    }

                    return messages
                }
                .reduce(
                    [],
                    +
                )
        }
    }
}

extension Array where Element == PackageContent.Platform {
    var iOSVersion: String? {
        first(where: \.platformName == "ios")?.version
    }

    var macOSVersion: String? {
        first(where: \.platformName == "macos")?.version
    }

    var tvOSVersion: String? {
        first(where: \.platformName == "tvos")?.version
    }

    var watchOSVersion: String? {
        first(where: \.platformName == "watchos")?.version
    }
}
