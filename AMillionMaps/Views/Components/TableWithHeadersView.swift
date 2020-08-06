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

struct TableWithHeadersView<Content: View, RowData: Hashable, ColData: Hashable>: View {
  @State private var xOffset: CGFloat = 0
  @State private var yOffset: CGFloat = 0

  @State private var xScrollOffset: CGFloat = 0
  @State private var yScrollOffset: CGFloat = 0

  private var xTotalOffset: CGFloat { xOffset + xScrollOffset }
  private var yTotalOffset: CGFloat { yOffset + yScrollOffset }

  @Binding private var rows: [RowData]
  @Binding private var cols: [ColData]

  let cellBuilder: (RowData, ColData) -> Content
  let rowHeaderBuilder: (RowData) -> Content
  let colHeaderBuilder: (ColData) -> Content

  private let columnWidth: CGFloat = 100
  private let rowHeight: CGFloat = 30

  let timestamp = Timestamp()

  init(
    _ rows: Binding<[RowData]>,
    _ cols: Binding<[ColData]>,
    _ rowHeaderBuilder: @escaping (RowData) -> Content,
    _ colHeaderBuilder: @escaping (ColData) -> Content,
    _ cellBuilder: @escaping (RowData, ColData) -> Content
  ) {
    // TODO: Show only those in window

    _rows = rows
    _cols = cols
    self.cellBuilder = cellBuilder
    self.rowHeaderBuilder = rowHeaderBuilder
    self.colHeaderBuilder = colHeaderBuilder
  }

  var body: some View {
    GeometryReader { geometry in
      self.listView(geometry)
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }

  private func listView(_ geometry: GeometryProxy) -> some View {
    let contentHeight: CGFloat = CGFloat(rows.count + 1) * rowHeight
    let contentWidth: CGFloat = CGFloat(cols.count + 1) * columnWidth

    var baseOffsetY: CGFloat = (contentHeight / 2 - geometry.size.height / 2)
    var baseOffsetX: CGFloat = (contentWidth / 2 - geometry.size.width / 2)

    if baseOffsetX < 0 {
      baseOffsetX = 0
    }

    if baseOffsetY < 0 {
      baseOffsetY = 0
    }

    let colRangeStart = max(0, Int(-xTotalOffset / columnWidth) - 1)
    let colRangeEnd = min(cols.count, colRangeStart + Int(geometry.size.width / columnWidth) + 2)
    let colRange = colRangeStart ..< colRangeEnd

    let rowRangeStart = max(0, Int(-yTotalOffset / rowHeight) - 1)
    let rowRangeEnd = min(rows.count, rowRangeStart + Int(geometry.size.height / rowHeight) + 2)
    let rowRange = rowRangeStart ..< rowRangeEnd

    let drag = DragGesture().onChanged { value in
      self.xScrollOffset = value.translation.width
      self.yScrollOffset = value.translation.height
      self.timestamp.printTimestamp()
      print(value.location)
    }.onEnded { value in
      withAnimation {
        self.xOffset += value.predictedEndTranslation.width
        self.yOffset += value.predictedEndTranslation.height

        self.onDragEnded(geometry)
      }
    }

    return VStack(spacing: 0) {
      HStack(spacing: 0) {
        Text(String("x")).frame(width: self.columnWidth, height: self.rowHeight).border(Color.green, width: 4)

        ZStack {
          Rectangle().fill(Color.white).frame(width: contentWidth - self.columnWidth, height: self.rowHeight)
          HStack(spacing: 0) {
            Spacer().frame(width: CGFloat(colRange.startIndex) * self.columnWidth, height: self.rowHeight)

            ForEach(colRange, id: \.hashValue) { colValue in
              self.colHeaderBuilder(self.cols[colValue]).frame(width: self.columnWidth, height: self.rowHeight).border(Color.blue, width: 4)
            }

            Spacer().frame(width: CGFloat(cols.count - colRange.endIndex) * self.columnWidth, height: self.rowHeight)

            if contentWidth <= geometry.size.width {
              Spacer()
            }
          }
        }.offset(x: self.xTotalOffset).clipped()
      }

      HStack(spacing: 0) {
        ZStack {
          Rectangle().fill(Color.white).frame(width: self.columnWidth, height: contentHeight - self.rowHeight)

          VStack(spacing: 0) {
            Spacer().frame(width: self.columnWidth, height: CGFloat(rowRange.startIndex) * self.rowHeight)

            ForEach(rowRange, id: \.hashValue) { rowValue in
              self.rowHeaderBuilder(self.rows[rowValue]).frame(width: self.columnWidth, height: self.rowHeight).border(Color.blue, width: 4)
            }

            Spacer().frame(width: self.columnWidth, height: CGFloat(rows.count - rowRange.endIndex) * self.rowHeight)

            if contentHeight <= geometry.size.height {
              Spacer()
            }
          }
        }

        HStack(spacing: 0) {
          ZStack {
            Rectangle().fill(Color.white).frame(width: contentWidth - self.columnWidth, height: contentHeight - self.rowHeight)
            HStack(spacing: 0) {
              Spacer().frame(width: CGFloat(colRange.startIndex) * self.columnWidth, height: self.rowHeight)

              ForEach(colRange, id: \.hashValue) { colValue in
                VStack(spacing: 0) {
                  Spacer().frame(width: self.columnWidth, height: CGFloat(rowRange.startIndex) * self.rowHeight)

                  ForEach(rowRange, id: \.hashValue) { rowValue in
                    self.cellBuilder(self.rows[rowValue], self.cols[colValue]).frame(width: self.columnWidth, height: self.rowHeight)
                      .border(Color.red, width: 4)
                  }

                  Spacer().frame(width: self.columnWidth, height: CGFloat(self.rows.count - rowRange.endIndex) * self.rowHeight)

                  if contentHeight <= geometry.size.height {
                    Spacer()
                  }
                }
              }

              Spacer().frame(width: CGFloat(cols.count - colRange.endIndex) * self.columnWidth, height: self.rowHeight)

              if contentWidth <= geometry.size.width {
                Spacer()
              }
            }
          }
        }.offset(x: self.xTotalOffset).clipped()
      }.offset(y: self.yTotalOffset).clipped()
    }
    .offset(x: baseOffsetX, y: baseOffsetY)
    .clipped()
    .gesture(drag)
  }

  func onDragEnded(_ geometry: GeometryProxy) {
    print("ENDED")
    if xOffset > 0 {
      xOffset = 0
    }

    let minXOffset = min(geometry.size.width - CGFloat(cols.count) * columnWidth, 0)

    if xOffset < minXOffset {
      xOffset = minXOffset
    }

    if yOffset > 0 {
      yOffset = 0
    }

    let minYOffset = min(geometry.size.height - CGFloat(rows.count + 1) * rowHeight, 0)

    if yOffset < minYOffset {
      yOffset = minYOffset
    }

    xScrollOffset = 0
    yScrollOffset = 0
  }
}

// struct TableWithHeadersView_Previews: PreviewProvider {
//  static var previews: some View {
//    TableWithHeadersView()
//  }
// }
