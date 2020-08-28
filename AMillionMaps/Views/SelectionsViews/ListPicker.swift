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
  @State var counter = 0

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
          HStack(spacing: 0) {
            // This is an ugly hack to update the list on click
            Text("\(self.counter)").frame(width: 0)
            Button(action: { self.selected = self.selections[index]
              self.counter += 1
            }) {
              self.viewBuilder(self.selections[index], self.selections[index].id == self.selected.id)
            }
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
  @State var counter = 0

  let viewBuilder: (Data, Bool) -> Content
  let action: (() -> Void)?

  init(_ selections: Binding<[DataState<Data>]>, action: (() -> Void)? = nil, @ViewBuilder viewBuilder: @escaping (Data, Bool) -> Content) {
    _selections = selections
    self.action = action
    self.viewBuilder = viewBuilder
  }

  var body: some View {
    ScrollView {
      VStack {
        ForEach(self.selections.indices) {
          index in
          HStack(spacing: 0) {
            // This is an ugly hack to update the list on click
            Text("\(self.counter)").frame(width: 0)
            Button(action: {
              self.selections[index].enabled.toggle()
              self.counter += 1
              self.action?()
          }) {
              self.viewBuilder(self.selections[index].data, self.selections[index].enabled)
            }
          }
        }
      }
    }
  }
}

struct OptionalListPicker<Content: View, Data: Hashable>: View {
  @Binding var selections: [Data]
  @Binding var selected: Data?
  @State var counter = 0

  let viewBuilder: (Data, Bool) -> Content

  init(_ selections: Binding<[Data]>, selected: Binding<Data?>, _ viewBuilder: @escaping (Data, Bool) -> Content) {
    _selections = selections
    _selected = selected
    self.viewBuilder = viewBuilder
  }

  var body: some View {
    ScrollView {
      VStack {
        Button(action: { self.selected = nil
          self.counter += 1
        }) {
          HStack {
            Text("None")
            Spacer()
          }
        }

        ForEach(self.selections.indices) {
          index in
          HStack(spacing: 0) {
            // This is an ugly hack to update the list on click
            Text("\(self.counter)").frame(width: 0)
            Button(action: { self.selected = self.selections[index]
              self.counter += 1
            }) {
              self.viewBuilder(self.selections[index], self.selections[index] == self.selected)
            }
          }
        }
      }
    }
  }
}
