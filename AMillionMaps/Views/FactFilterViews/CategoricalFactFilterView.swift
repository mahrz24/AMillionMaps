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
        MultiSelect<ZStack, String>($selectedCategories) {
          category, enabled in
          ZStack {
            self.rectangle(enabled)
            Text(category).lineLimit(1).font(.footnote).foregroundColor(Color.white)
          }
        }
      }
    }.onAppear {
      self.selectedCategories = self.fact.categoryLabels!.map { DataState<String>(enabled: false, data: $0) }
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
