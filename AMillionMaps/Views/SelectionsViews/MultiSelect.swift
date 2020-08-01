
//
//  MultiSelect.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 25.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct MultiSelectToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
    }.onTapGesture { configuration.isOn.toggle() }
  }
}

struct DataState<T: Identifiable>: Identifiable {
  var id: T.ID { data.id }
  var enabled: Bool
  var data: T
}

struct MultiSelect<Content: View, Data: Identifiable>: View {
  @Binding var selections: [DataState<Data>]

  let viewBuilder: (Data, Bool) -> Content

  init(_ selections: Binding<[DataState<Data>]>, _ viewBuilder: @escaping (Data, Bool) -> Content) {
    _selections = selections
    self.viewBuilder = viewBuilder
  }

  var body: some View {
    ForEach(self.selections.indices, id: \.self) {
      index in
      Toggle(isOn: self.$selections[index].enabled) {
        self.viewBuilder(self.selections[index].data, self.selections[index].enabled)
      }.toggleStyle(MultiSelectToggleStyle())
    }
  }
}

// struct MultiSelect_Previews: PreviewProvider {
//    static var previews: some View {
//        MultiSelect()
//    }
// }
