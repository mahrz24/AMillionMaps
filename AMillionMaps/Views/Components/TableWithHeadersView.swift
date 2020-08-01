//
//  TableWithHeadersView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 27.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct ViewHeightKey: PreferenceKey {
  static var defaultValue: CGSize { CGSize(width: 0, height: 0) }
  static func reduce(value: inout Value, nextValue: () -> Value) {
    let next = nextValue()
    value.width = value.width + next.width
    value.height = value.height + next.height
  }
}

extension ViewHeightKey: ViewModifier {
  func body(content: Content) -> some View {
    content.background(GeometryReader { proxy in
      Color.clear.preference(key: Self.self, value: proxy.size)
        })
  }
}

struct TableWithHeadersView: View {
  @State private var xOffset: CGFloat = 0
  @State private var yOffset: CGFloat = 0

  @State private var xScrollOffset: CGFloat = 0
  @State private var yScrollOffset: CGFloat = 0

  private var xTotalOffset: CGFloat { xOffset + xScrollOffset }
  private var yTotalOffset: CGFloat { yOffset + yScrollOffset }

  @State private var contentWidth: CGFloat = 0
  @State private var contentHeight: CGFloat = 0

  private let columnWidth: CGFloat = 100
  private let rowHeight: CGFloat = 30

  private var numberOfCols: Int = 30
  private var numberOfRows: Int = 20

  var body: some View {
    GeometryReader { geometry in
      self.listView(geometry)
        .modifier(ViewHeightKey())
        .onPreferenceChange(ViewHeightKey.self) { size in
          print("Size: \(size)")
          self.contentWidth = size.width
          self.contentHeight = size.height
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .clipped()
    }
  }

  private func listView(_ geometry: GeometryProxy) -> some View {
    let baseOffsetY: CGFloat = (contentHeight / 2 - geometry.size.height / 2)
    let baseOffsetX: CGFloat = (contentWidth / 2 - geometry.size.width / 2)

    return VStack(spacing: 0) {
      HStack(spacing: 0) {
        Text(String("x")).frame(width: self.columnWidth, height: self.rowHeight).border(Color.green, width: 4)

        HStack(spacing: 0) {
          ForEach(0 ..< self.numberOfCols, id: \.hashValue) { rowIndex in
            Text(String("\(rowIndex)")).frame(width: self.columnWidth, height: self.rowHeight).border(Color.blue, width: 4)
          }
        }.offset(x: self.xTotalOffset).clipped()
      }

      HStack(spacing: 0) {
        VStack(spacing: 0) {
          ForEach(0 ..< self.numberOfRows, id: \.hashValue) { rowIndex in
            Text(String("\(rowIndex)")).frame(width: self.columnWidth, height: self.rowHeight).border(Color.blue, width: 4)
          }
        }

        HStack(spacing: 0) {
          ForEach(0 ..< numberOfCols, id: \.hashValue) { colIndex in
            VStack(spacing: 0) {
              ForEach(0 ..< self.numberOfRows, id: \.hashValue) { rowIndex in
                Text(String("\(rowIndex), \(colIndex)")).frame(width: self.columnWidth, height: self.rowHeight).border(Color.red, width: 4)
              }
            }
          }
        }.offset(x: self.xTotalOffset).clipped()
      }.offset(y: self.yTotalOffset).clipped()
    }
    .offset(x: baseOffsetX, y: baseOffsetY)
    .gesture(DragGesture().onChanged { value in
      self.xScrollOffset = value.translation.width
      self.yScrollOffset = value.translation.height
    }.onEnded { _ in
      self.xOffset += self.xScrollOffset
      self.yOffset += self.yScrollOffset
      self.xScrollOffset = 0
      self.yScrollOffset = 0
      })
  }
}

struct TableWithHeadersView_Previews: PreviewProvider {
  static var previews: some View {
    TableWithHeadersView()
  }
}
