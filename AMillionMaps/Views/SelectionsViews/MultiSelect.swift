
//
//  MultiSelect.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 25.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct ExpandableButtonItem: Identifiable {
  let id = UUID()
  let label: String
  private(set) var action: () -> Void
}

struct ExpandableButtonPanel: View {
  let label: String
  let items: [ExpandableButtonItem]
  let size: CGFloat
  let overlayWidth: CGFloat

  private let cornerRadius: CGFloat = 5

  private let shadowColor = Color.black.opacity(0.4)
  private let shadowPosition: (x: CGFloat, y: CGFloat) = (x: 2, y: 2)
  private let shadowRadius: CGFloat = 2

  @State private var isExpanded = false

  private var roundedCorners: UIRectCorner {
    if isExpanded {
      return [.topLeft, .topRight]
    } else {
      return [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }
  }

  var body: some View {
    VStack {
      Button(label, action: {
        withAnimation {
          self.isExpanded.toggle()
        }
      })
        .frame(width: size, height: size)
    }
    .background(Color(UIColor.systemPurple))
    .cornerRadius(cornerRadius, corners: self.roundedCorners)
    .font(.title)
    .overlay(VStack {
      Spacer().frame(height: self.size)
      VStack {
        ForEach(items) { item in
          Button(action: item.action) {
            Text(item.label)
          }
          .frame(width: self.overlayWidth,
                 height: self.isExpanded ? self.size : 0)
        }
      }.background(Color(UIColor.gray))
        .cornerRadius(cornerRadius, corners: [.topLeft, .bottomLeft, .bottomRight])
        .font(.title)
      }, alignment: .topTrailing)
  }
}

struct MultiSelectToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
    }.onTapGesture { configuration.isOn.toggle() }
  }
}

//struct DataState<T: Identifiable & CustomStringConvertible>: Identifiable {
//  var id: T.ID { data.id }
//  var enabled: Bool
//  var data: T
//}

struct MultiSelect<Content: View, Data: Identifiable & CustomStringConvertible>: View {
  @Binding var selections: [DataState<Data>]

  let viewBuilder: (Data, Bool) -> Content

  init(_ selections: Binding<[DataState<Data>]>, _ viewBuilder: @escaping (Data, Bool) -> Content) {
    _selections = selections
    self.viewBuilder = viewBuilder
  }

  var body: some View {
    HStack {
      ForEach(self.selections.indices, id: \.self) {
        index in
        Toggle(isOn: self.$selections[index].enabled) {
          self.viewBuilder(self.selections[index].data, self.selections[index].enabled)
        }.toggleStyle(MultiSelectToggleStyle())
      }
      ExpandableButtonPanel(label: "➕",
                            items: self.selections.map {
                              selection in ExpandableButtonItem(label: String(describing: selection.data)) {
                                print("Sunshine")
                              }
                            },
                            size: 50,
                            overlayWidth: 200).padding().zIndex(10)
    }
  }
}

// struct MultiSelect_Previews: PreviewProvider {
//    static var previews: some View {
//        MultiSelect()
//    }
// }
