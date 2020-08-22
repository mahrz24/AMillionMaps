//
//  FactSelectionView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 11.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct Checkbox: View {
  let selected: Bool
  let label: String

  var body: some View {
    HStack {
      Image(systemName: selected ? "checkmark.square" : "square")
        .resizable()
        .frame(width: 14, height: 14)
      Text(label)
      Spacer()
    }
  }
}

struct ListPicker<Content: View, Data: Identifiable>: View {
  @Binding var selections: [Data]
  @Binding var selected: Data

  let viewBuilder: (Data, Bool) -> Content

  init(_ selections: Binding<[Data]>, selected: Binding<Data>, _ viewBuilder: @escaping (Data, Bool) -> Content) {
    _selections = selections
    _selected = selected
    self.viewBuilder = viewBuilder
  }

  var body: some View {
    ScrollView {
      VStack {
        ForEach(self.selections.indices) {
          index in
          Button(action: { self.selected = self.selections[index] }) {
            self.viewBuilder(self.selections[index], self.selections[index].id == self.selected.id)
          }
        }
      }
    }
  }
}

struct DataState<T: Identifiable>: Identifiable {
  var id: T.ID { data.id }
  var enabled: Bool
  var data: T
}


struct MultiListPicker<Content: View, Data: Identifiable>: View {
  @Binding var selections: [DataState<Data>]

  let viewBuilder: (Data, Bool) -> Content
  let action: (() -> ())?

  init(_ selections: Binding<[DataState<Data>]>, action: (() -> ())? = nil, @ViewBuilder viewBuilder: @escaping (Data, Bool) -> Content) {
    _selections = selections
    self.action = action
    self.viewBuilder = viewBuilder
  }

  var body: some View {
    ScrollView {
      VStack {
        ForEach(self.selections.indices) {
          index in
          Button(action: {
            self.selections[index].enabled.toggle()
            self.action?()
          }) {
            self.viewBuilder(self.selections[index].data, self.selections[index].enabled)
          }
        }
      }
    }
  }
}

struct OptionalListPicker<Content: View, Data: Hashable>: View {
  @Binding var selections: [Data]
  @Binding var selected: Data?

  let viewBuilder: (Data, Bool) -> Content

  init(_ selections: Binding<[Data]>, selected: Binding<Data?>, _ viewBuilder: @escaping (Data, Bool) -> Content) {
    _selections = selections
    _selected = selected
    self.viewBuilder = viewBuilder
  }

  var body: some View {
    ScrollView {
      VStack {
        Button(action: { self.selected = nil }) {
          HStack {
            Text("None")
            Spacer()
          }
        }

        ForEach(self.selections.indices) {
          index in
          Button(action: { self.selected = self.selections[index] }) {
            self.viewBuilder(self.selections[index], self.selections[index] == self.selected)
          }
        }
      }
    }
  }
}
