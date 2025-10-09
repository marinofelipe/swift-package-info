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

internal import Foundation

public nonisolated struct SizeOnDisk: Equatable, Sendable {
  /// Literal size quantity, in `Kilobytes`
  public let amount: Int
  public let formatted: String

  public init(
    amount: Int,
    formatted: String
  ) {
    self.amount = amount
    self.formatted = formatted
  }

  public static let empty: SizeOnDisk = .init(
    amount: 0,
    formatted: "0.0"
  )
}

extension SizeOnDisk: CustomStringConvertible {
  public var description: String {
    "Size on disk: \(formatted)"
  }
}

extension SizeOnDisk: CustomConsoleMessageConvertible {
  public var message: ConsoleMessage {
    .init(
      text: description,
      color: .yellow,
      isBold: false
    )
  }
}

extension SizeOnDisk: AdditiveArithmetic {
  public static let zero: SizeOnDisk = .empty

  public static func - (lhs: SizeOnDisk, rhs: SizeOnDisk) -> SizeOnDisk {
    let finalAmount = lhs.amount - rhs.amount

    return .init(
      amount: finalAmount,
      formatted: URL.fileByteCountFormatter.string(
        for: finalAmount
      ) ?? ""
    )
  }

  public static func + (lhs: SizeOnDisk, rhs: SizeOnDisk) -> SizeOnDisk {
    let finalAmount = lhs.amount + rhs.amount

    return .init(
      amount: finalAmount,
      formatted: URL.fileByteCountFormatter.string(
        for: finalAmount
      ) ?? ""
    )
  }
}
