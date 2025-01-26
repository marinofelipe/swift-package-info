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

import Core
import Foundation

public struct PlatformsProvider {
  public static func fetchInformation(
    for swiftPackage: SwiftPackage,
    package: PackageWrapper,
    xcconfig: URL?,
    verbose: Bool
  ) async throws -> ProvidedInfo {
    .init(
      providerName: "Platforms",
      providerKind: .platforms,
      information: PlatformsInformation(
        platforms: package.platforms
      )
    )
  }
}

struct PlatformsInformation: Equatable, Encodable, CustomConsoleMessagesConvertible {
  let platforms: [PackageWrapper.Platform]
  let iOS: String?
  let macOS: String?
  let tvOS: String?
  let watchOS: String?

  var messages: [ConsoleMessage] { buildConsoleMessages() }

  init(platforms: [PackageWrapper.Platform]) {
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
      [
        .init(
          text: "System default",
          hasLineBreakAfter: false
        )
      ]
    } else {
      platforms
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

extension Array where Element == PackageWrapper.Platform {
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
