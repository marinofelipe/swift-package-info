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
        let messages: [ConsoleMessage]
        if packageContent.platforms.isEmpty {
            messages = [
                .init(
                    text: "System default",
                    hasLineBreakAfter: false
                )
            ]
        } else {
            messages = packageContent.platforms
                .map { platform -> [ConsoleMessage] in
                    let isLastPlatforms = platform == packageContent.platforms.last

                    var messages = [
                        ConsoleMessage(
                            text: "\(platform.platformName) v. \(platform.version)",
                            isBold: true,
                            hasLineBreakAfter: false
                        )
                    ]

                    if isLastPlatforms == false {
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

        return .success(
            .init(
                providerName: "Platforms",
                messages: messages
            )
        )
    }
}
