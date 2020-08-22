//
//  NumericFactView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 03.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Combine
import Resolver
import Sliders
import SwiftUI

struct CategoricalFactFilterView: View {
  var fact: ConstantCategoricalFact
  var action: (ConditionValue) -> Void
  @Injected var countryProvider: CountryProvider

  @State private var selectedCategories: [DataState<String>] = []

  var body: some View {
    
    VStack {
      HStack {
        Text(fact.id).font(.subheadline)
        Spacer()
      }

      HStack {
        HStack {
        ForEach(self.selectedCategories, id: \.id) {
            category in
            ZStack {
              self.rectangle(category.enabled)
              Text(category.data).lineLimit(1).font(.footnote).foregroundColor(Color.white)
            }
          }
        }
        SidePanelButton(panelBuilder: {
          MultiListPicker(self.$selectedCategories, action: {
            self.action(ConditionValue.categorical(self.selectedCategories.filter(\.enabled).map(\.data)))
          }) {
            category, selected in Checkbox(selected: selected, label: category)
          }
        }) {
         Text("+")
        }
      }
    }.onAppear {
      self.selectedCategories = self.fact.categoryLabels!.map { DataState<String>(enabled: true, data: $0) }
    }
  }

  func rectangle(_ enabled: Bool) -> some View {
    if enabled {
      return Rectangle().fill(Color.red).cornerRadius(4)
    } else {
      return Rectangle().fill(Color.gray).cornerRadius(4)
    }
  }
}
