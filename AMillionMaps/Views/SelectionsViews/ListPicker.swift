//
//  FactSelectionView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 11.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct ListPicker<Content: View, Data: Hashable>: View {
  
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
              self.viewBuilder(self.selections[index], self.selections[index] == self.selected)
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

