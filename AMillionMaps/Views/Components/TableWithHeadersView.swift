//
//  TableWithHeadersView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 27.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct ViewSizeKey: PreferenceKey {
  static var defaultValue: CGSize { CGSize(width: 0, height: 0) }
  static func reduce(value: inout Value, nextValue: () -> Value) {
    let next = nextValue()
    value.width = value.width + next.width
    value.height = value.height + next.height
  }
}

extension ViewSizeKey: ViewModifier {
  func body(content: Content) -> some View {
    content.background(GeometryReader { proxy in
      Color.clear.preference(key: Self.self, value: proxy.size)
        })
  }
}

class Timestamp {
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS "
    return formatter
  }()

  func printTimestamp() {
    print(dateFormatter.string(from: Date()))
  }
}

struct TableWithHeadersView<Content: View, RowHeader: View, ColHeader: View, RowData: Hashable, ColData: Hashable>: View {
  @State private var xOffset: CGFloat = 0
  @State private var yOffset: CGFloat = 0

  @State private var xScrollOffset: CGFloat = 0
  @State private var yScrollOffset: CGFloat = 0

  @State private var xOldOffset: CGFloat = 0
  @State private var yOldOffset: CGFloat = 0

  private var xTotalOffset: CGFloat { xOffset + xScrollOffset }
  private var yTotalOffset: CGFloat { yOffset + yScrollOffset }

  @Binding private var rows: [RowData]
  @Binding private var cols: [ColData]

  @Environment(\.colorTheme) var colorTheme: ColorTheme

  let cellBuilder: (RowData, ColData) -> Content
  let rowHeaderBuilder: (RowData) -> RowHeader
  let colHeaderBuilder: (ColData) -> ColHeader
  let colWidth: (ColData) -> CGFloat

  private let rowHeight: CGFloat
  private let headerColWidth: CGFloat

  let timestamp = Timestamp()

  init(
    _ rows: Binding<[RowData]>,
    _ cols: Binding<[ColData]>,
    colWidth: @escaping (ColData) -> CGFloat,
    headerColWidth: CGFloat,
    rowHeight: CGFloat,
    _ rowHeaderBuilder: @escaping (RowData) -> RowHeader,
    _ colHeaderBuilder: @escaping (ColData) -> ColHeader,
    _ cellBuilder: @escaping (RowData, ColData) -> Content
  ) {
    // TODO: Show only those in window

    _rows = rows
    _cols = cols
    self.cellBuilder = cellBuilder
    self.rowHeaderBuilder = rowHeaderBuilder
    self.colHeaderBuilder = colHeaderBuilder
    self.rowHeight = rowHeight
    self.colWidth = colWidth
    self.headerColWidth = headerColWidth
  }

  var body: some View {
    GeometryReader { geometry in
      self.listView(geometry)
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }

  var contentHeight: CGFloat { CGFloat(rows.count + 1) * rowHeight }
  var contentWidth: CGFloat { cols.map(colWidth).reduce(0, +) + headerColWidth }

  private func columnRange(_ xOffset: CGFloat, _ width: CGFloat) -> Range<Int> {
    var accumulatedWidth: CGFloat = 0
    var startIndex = 0
    var endIndex = 0
    for col in cols {
      accumulatedWidth += colWidth(col)
      if accumulatedWidth < xOffset {
        startIndex += 1
      }

      if accumulatedWidth <= xOffset + width {
        endIndex += 1
      }
    }

    return startIndex ..< min(cols.count, endIndex + 1)
  }

  private func rangeColWidth(_ colRange: Range<Int>) -> CGFloat {
    cols[colRange].map(colWidth).reduce(0, +)
  }

  private func checkOffsets(_ size: CGSize) {
    if xOffset > 0 {
      xOffset = 0
    }

    let minXOffset = min(size.width - contentWidth, 0)

    if xOffset < minXOffset {
      xOffset = minXOffset
    }

    if yOffset > 0 {
      yOffset = 0
    }

    let minYOffset = min(size.height - contentHeight, 0)

    if yOffset < minYOffset {
      yOffset = minYOffset
    }
  }

  private func listView(_ geometry: GeometryProxy) -> some View {
    var baseOffsetY: CGFloat = (contentHeight / 2 - geometry.size.height / 2)
    var baseOffsetX: CGFloat = (contentWidth / 2 - geometry.size.width / 2)

    if baseOffsetX < 0 {
      baseOffsetX = 0
    }

    if baseOffsetY < 0 {
      baseOffsetY = 0
    }
    DispatchQueue.main.async {
      self.checkOffsets(geometry.size)
    }

    let newColRange = columnRange(-xTotalOffset, geometry.size.width)
    let oldColRange = columnRange(-xOldOffset, geometry.size.width)

    let colRange = min(newColRange.startIndex, oldColRange.startIndex) ..< max(newColRange.endIndex, oldColRange.endIndex)

    let rowRangeStart = max(0, min(rows.count - Int(geometry.size.height / rowHeight), Int(-yTotalOffset / rowHeight) - 1))
    let rowRangeEnd = min(rows.count, rowRangeStart + Int(geometry.size.height / rowHeight) + 2)

    let oldRowRangeStart = max(0, min(rows.count - Int(geometry.size.height / rowHeight), Int(-yOldOffset / rowHeight) - 1))
    let oldRowRangeEnd = min(rows.count, oldRowRangeStart + Int(geometry.size.height / rowHeight) + 2)

    let rowRange = min(rowRangeStart, oldRowRangeStart) ..< max(rowRangeEnd, oldRowRangeEnd)
    print(rowRange)

    let drag = DragGesture().onChanged { value in

      self.xOldOffset = self.xOffset
      self.yOldOffset = self.yOffset

      self.xScrollOffset = value.translation.width
      self.yScrollOffset = value.translation.height

    }.onEnded { value in
      self.xOldOffset = self.xOffset + self.xScrollOffset
      self.yOldOffset = self.yOffset + self.yScrollOffset

      withAnimation {
        self.xOffset += value.predictedEndTranslation.width
        self.yOffset += value.predictedEndTranslation.height

        self.checkOffsets(geometry.size)

        self.xScrollOffset = 0
        self.yScrollOffset = 0
        // TODO: add completion modifier:
        // self.xOldOffset = self.xOffset
        // self.yOldOffset = self.yOffset
      }
    }

    return VStack(spacing: 0) {
      HStack(spacing: 0) {
        Spacer().frame(width: self.headerColWidth, height: self.rowHeight)

        ZStack {
          Rectangle().fill(self.colorTheme.uiBackground.color).frame(width: contentWidth - self.headerColWidth, height: self.rowHeight)
          HStack(spacing: 0) {
            Spacer().frame(width: self.rangeColWidth(0 ..< colRange.startIndex), height: self.rowHeight)

            ForEach(colRange, id: \.hashValue) { colValue in
              self.colHeaderBuilder(self.cols[colValue]).padding(2).frame(width: self.colWidth(self.cols[colValue]), height: self.rowHeight)
            }

            Spacer().frame(width: self.rangeColWidth(colRange.endIndex ..< cols.count), height: self.rowHeight)

            if contentWidth <= geometry.size.width {
              Spacer()
            }
          }
        }.offset(x: self.xTotalOffset).clipped()
      }

      HStack(spacing: 0) {
        ZStack {
          Rectangle().fill(self.colorTheme.uiBackground.color).frame(width: self.headerColWidth, height: contentHeight - self.rowHeight)

          VStack(spacing: 0) {
            Spacer().frame(width: self.headerColWidth, height: CGFloat(rowRange.startIndex) * self.rowHeight)

            ForEach(rowRange, id: \.hashValue) { rowValue in
              self.rowHeaderBuilder(self.rows[rowValue]).frame(width: self.headerColWidth, height: self.rowHeight)
            }

            Spacer().frame(width: self.headerColWidth, height: CGFloat(rows.count - rowRange.endIndex) * self.rowHeight)

            if contentHeight <= geometry.size.height {
              Spacer()
            }
          }
        }

        HStack(spacing: 0) {
          ZStack {
            Rectangle().fill(self.colorTheme.uiBackground.color)
              .frame(width: contentWidth - headerColWidth, height: contentHeight - self.rowHeight)
            HStack(spacing: 0) {
              Spacer().frame(width: self.rangeColWidth(0 ..< colRange.startIndex), height: self.rowHeight)

              ForEach(colRange, id: \.hashValue) { colValue in
                VStack(spacing: 0) {
                  Spacer().frame(width: self.colWidth(self.cols[colValue]), height: CGFloat(rowRange.startIndex) * self.rowHeight)

                  ForEach(rowRange, id: \.hashValue) { rowValue in
                    self.cellBuilder(self.rows[rowValue], self.cols[colValue])
                      .frame(width: self.colWidth(self.cols[colValue]), height: self.rowHeight)
                  }

                  Spacer()
                    .frame(width: self.colWidth(self.cols[colValue]), height: CGFloat(self.rows.count - rowRange.endIndex) * self.rowHeight)

                  if self.contentHeight <= geometry.size.height {
                    Spacer()
                  }
                }
              }

              Spacer().frame(width: self.rangeColWidth(colRange.endIndex ..< cols.count), height: self.rowHeight)

              if self.contentWidth <= geometry.size.width {
                Spacer()
              }
            }
          }
        }.offset(x: self.xTotalOffset).clipped()
      }.offset(y: self.yTotalOffset).clipped().contentShape(Rectangle().offset(x: 0, y: 0).size(width: geometry.size.width,
                                                                                                height: geometry.size.height))
//        .overlay(Rectangle().offset(x: 0, y: 0)
//          .size(width: geometry.size.width,
//                height: geometry
//                  .size
//                  .height)
//          .foregroundColor(Color
//            .red)
//          .opacity(0.5))
        .gesture(drag)
    }
    .offset(x: baseOffsetX, y: baseOffsetY)
    .clipped()
  }
}

// struct TableWithHeadersView_Previews: PreviewProvider {
//  static var previews: some View {
//    TableWithHeadersView()
//  }
// }
