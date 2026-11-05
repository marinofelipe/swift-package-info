//  Copyright (c) 2026 Felipe Marino
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

/// The size impact of a Swift Package product on an app.
public struct BinarySize: Equatable, Sendable {
  /// Uncompressed size of the app bundle, close to the size the app takes on disk once installed.
  public let install: SizeOnDisk
  /// Compressed size of the app bundle packaged as an IPA, an estimate of the download size.
  ///
  /// It doesn't account for App Store encryption of the executable, which reduces how much it can be compressed,
  /// nor for App Thinning, so the actual download size may differ.
  public let estimatedDownload: SizeOnDisk

  public init(
    install: SizeOnDisk,
    estimatedDownload: SizeOnDisk
  ) {
    self.install = install
    self.estimatedDownload = estimatedDownload
  }

  public static let zero: BinarySize = .init(
    install: .zero,
    estimatedDownload: .zero
  )

  public static func - (lhs: BinarySize, rhs: BinarySize) -> BinarySize {
    .init(
      install: lhs.install - rhs.install,
      estimatedDownload: lhs.estimatedDownload - rhs.estimatedDownload
    )
  }
}
