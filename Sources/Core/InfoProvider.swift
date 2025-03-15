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

import Foundation

public struct InfoProviderError: LocalizedError, Equatable, CustomConsoleMessageConvertible {
  public let message: ConsoleMessage

  public private(set) var errorDescription: String?

  public init(
    localizedError: LocalizedError,
    customConsoleMessage: ConsoleMessage? = nil
  ) {
    self.errorDescription = localizedError.errorDescription
    self.message = customConsoleMessage ?? .init(
      text: localizedError.errorDescription ?? "",
      color: .red,
      isBold: true,
      hasLineBreakAfter: true
    )
  }
}

public enum ProviderKind: String, CodingKey {
  case binarySize
  case dependencies
  case platforms
}

public typealias InfoProvider = @Sendable (
  _ packageDefinition: PackageDefinition,
  _ resolvedPackage: PackageWrapper,
  _ xcconfig: URL?,
  _ verbose: Bool
) async throws -> ProvidedInfo
//throws(InfoProviderError) , typed throws only supported from macOS 15.0 runtime

public struct ProvidedInfo: Encodable, CustomConsoleMessagesConvertible, Sendable {
  public let providerName: String
  public let providerKind: ProviderKind
  public var messages: [ConsoleMessage] {
    informationMessagesConvertible.messages
  }
  
  private let informationEncoder: @Sendable (Encoder) throws -> Void
  private let informationMessagesConvertible: CustomConsoleMessagesConvertible
  
  public init<T>(
    providerName: String,
    providerKind: ProviderKind,
    information: T
  ) where T: Encodable, T: CustomConsoleMessagesConvertible {
    self.providerName = providerName
    self.providerKind = providerKind
    self.informationMessagesConvertible = information
    self.informationEncoder = { encoder in
      var container = encoder.singleValueContainer()
      try container.encode(information)
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    try informationEncoder(encoder)
  }
}
