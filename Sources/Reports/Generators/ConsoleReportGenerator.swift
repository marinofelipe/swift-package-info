//
//  ConsoleReportGenerator.swift
//
//  Acknowledgement: This piece of code is inspired by Raycast's script-commands repository:
//  https://github.com/unnamedd/script-commands/blob/Toolkit/Improvements/Tools/Toolkit/Sources/ToolkitLibrary/Core/Report/Report.swift
//
//  Created by Marino Felipe on 20.03.21.
//

import Core

@MainActor
struct ConsoleReportGenerator {
  private enum Size {
    static let cellMargin = 2
    static let numberOfColumns = 2
  }

  private static let mainTitle = "Swift Package Info"
  private static let providerNameColumnTitle = "Provider"
  private static let resultsColumnTitle = "Results"

  private let console: Console

  nonisolated init(console: Console) {
    self.console = console
  }

  func renderReport(
    for swiftPackage: SwiftPackage,
    providedInfos: [ProvidedInfo]
  ) {
    var firstColumnMaxContentSize = Self.providerNameColumnTitle.count
    var secondColumnMaxContentSize = Self.resultsColumnTitle.count

    providedInfos.forEach { providedInfo in
      if case let providerNameSize = providedInfo.providerName.count,
         providerNameSize > firstColumnMaxContentSize {
        firstColumnMaxContentSize = providerNameSize
      }

      let totalMessageSize = providedInfo.messages
        .map(\.text.count)
        .reduce(0, +)
      if totalMessageSize > secondColumnMaxContentSize {
        secondColumnMaxContentSize = totalMessageSize
      }
    }

    firstColumnMaxContentSize += Size.cellMargin
    secondColumnMaxContentSize += Size.cellMargin

    var maxWidthWithoutLeftRightSeparators = firstColumnMaxContentSize
    + secondColumnMaxContentSize
    + ((Size.numberOfColumns - 1) * Divider.pipe.rawValue.count) // in between columns separators

    let packageInfoRowWidth = swiftPackage.message.text.count + Size.cellMargin

    if packageInfoRowWidth > maxWidthWithoutLeftRightSeparators {
      let differenceInWidth = packageInfoRowWidth - maxWidthWithoutLeftRightSeparators
      maxWidthWithoutLeftRightSeparators += differenceInWidth

      let halfDifferenceInWidth = differenceInWidth / 2
      firstColumnMaxContentSize += halfDifferenceInWidth
      secondColumnMaxContentSize += halfDifferenceInWidth
      + ((Size.numberOfColumns - 1) * Divider.pipe.rawValue.count) // in between columns separators
    }

    console.lineBreak()
    renderVerticalDivider(widthsInBetweenSeparators: [maxWidthWithoutLeftRightSeparators])
    renderHorizontallyCenteredCell(
      maxWidth: maxWidthWithoutLeftRightSeparators,
      cell: .makeTitleCell(text: Self.mainTitle)
    )
    renderEmptyRow(size: maxWidthWithoutLeftRightSeparators)
    renderHorizontallyCenteredCell(
      maxWidth: maxWidthWithoutLeftRightSeparators,
      cell: .init(messages: [swiftPackage.message])
    )

    let columnsTotalSizes = [firstColumnMaxContentSize, secondColumnMaxContentSize]
    renderVerticalDivider(widthsInBetweenSeparators: columnsTotalSizes)

    let columnHeaderCells: [ReportCell] = [
      .makeColumnHeaderCell(
        title: Self.providerNameColumnTitle,
        size: firstColumnMaxContentSize
      ),
      .makeColumnHeaderCell(
        title: Self.resultsColumnTitle,
        size: secondColumnMaxContentSize
      )
    ]
    renderRow(for: columnHeaderCells)

    renderVerticalDivider(widthsInBetweenSeparators: columnsTotalSizes)

    providedInfos.forEach { providedInfo in
      let rowCells: [ReportCell] = [
        .makeProviderTitleCell(
          named: providedInfo.providerName,
          size: firstColumnMaxContentSize
        ),
        .makeForProvidedInfo(
          providedInfo: providedInfo,
          size: secondColumnMaxContentSize
        )
      ]

      renderRow(for: rowCells)
    }

    renderVerticalDivider(widthsInBetweenSeparators: columnsTotalSizes)
    console.write(
      .init(
        text: "> Total of ",
        isBold: false,
        hasLineBreakAfter: false
      )
    )
    console.write(
      .init(
        text: "\(providedInfos.count)",
        color: .cyan,
        isBold: true,
        hasLineBreakAfter: false
      )
    )
    console.write(
      .init(
        text: " \(providedInfos.count > 1 ? "providers" : "provider") used.",
        isBold: false, hasLineBreakAfter: true
      )
    )
    console.lineBreak()
  }
}

private extension ConsoleReportGenerator {
  func renderHorizontallyCenteredCell(maxWidth: Int, cell: ReportCell) {
    let halfMaxWidth = maxWidth / 2
    let halfCellWidth = cell.size / 2

    let leadingOffset = halfMaxWidth - halfCellWidth
    let titleLeadingMargin = String(
      repeating: Divider.space.rawValue,
      count: leadingOffset
    )

    let trailingOffset = maxWidth - (leadingOffset + cell.size)
    let titleTrailingMargin = String(
      repeating: Divider.space.rawValue,
      count: trailingOffset
    )

    console.write(Divider.pipe.message)
    console.write(
      .init(
        text: titleLeadingMargin,
        hasLineBreakAfter: false
      )
    )
    cell.messages.forEach(console.write)
    console.write(
      .init(
        text: titleTrailingMargin,
        hasLineBreakAfter: false
      )
    )
    console.write(.init(text: Divider.pipe.rawValue))
  }

  func renderRow(for cells: [ReportCell]) {
    console.write(Divider.pipe.message)

    cells.forEach { cell in
      var sizeToFillWithSpace = cell.size - cell.textSize
      console.write(Divider.space.message)
      sizeToFillWithSpace -= 1

      cell.messages.forEach(console.write)
      console.write(
        .init(
          text: String(
            repeating: Divider.space.rawValue,
            count: sizeToFillWithSpace
          ),
          hasLineBreakAfter: false
        )
      )
      console.write(Divider.pipe.message)
    }

    console.lineBreak()
  }

  func renderEmptyRow(size: Int) {
    console.write(Divider.pipe.message)
    console.write(
      .init(
        text: String(repeating: Divider.space.rawValue, count: size),
        hasLineBreakAfter: false
      )
    )
    console.write(Divider.pipe.message)
    console.lineBreak()
  }

  func renderVerticalDivider(widthsInBetweenSeparators: [Int]) {
    var divider = Divider.plus.rawValue

    widthsInBetweenSeparators.forEach { width in
      divider += String(repeating: Divider.minus.rawValue, count: width)
      divider += Divider.plus.rawValue
    }

    console.write(.init(text: divider))
  }
}

private enum Divider: String, CustomConsoleMessageConvertible {
  case minus = "-"
  case pipe = "|"
  case plus = "+"
  case space = " "

  var message: ConsoleMessage {
    .init(
      text: rawValue,
      hasLineBreakAfter: false
    )
  }
}
