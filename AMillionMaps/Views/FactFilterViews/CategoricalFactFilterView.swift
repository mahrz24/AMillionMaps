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

struct Chips: View {
  let titleKey: LocalizedStringKey // text or localisation value
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  var body: some View {
    HStack {
      Text(titleKey).lineLimit(1)
      Spacer()
    }
    .padding([.leading, .trailing], 10)
    .padding([.top, .bottom], 5)
    .cornerRadius(40) // rounded Corner
    .background(
      RoundedRectangle(cornerRadius: 40).softInnerShadow(RoundedRectangle(cornerRadius: 40), spread: 0.075, radius: 4)
        .foregroundColor(colorTheme.uiBackground.color)
    )
  }
}

struct MyPreferenceKey: PreferenceKey {
  static var defaultValue: MyPreferenceData = MyPreferenceData(size: CGSize.zero)

  static func reduce(value: inout MyPreferenceData, nextValue: () -> MyPreferenceData) {
    value = nextValue()
    print(value)
  }

  typealias Value = MyPreferenceData
}

struct MyPreferenceData: Equatable {
  let size: CGSize
  // you can give any name to this variable as usual.
}

struct CategoricalFactFilterView: View {
  var fact: ConstantCategoricalFact
  var action: (ConditionValue) -> Void
  @Injected var countryProvider: CountryProvider

  @State private var selectedCategories: [DataState<String>] = []
  @State var heightOfChips: CGFloat = .zero

  var body: some View {
    var width = CGFloat.zero
    var height = CGFloat.zero
    return VStack {
      HStack {
        Text(fact.id).font(.subheadline)
        Spacer()
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

      VStack {
        ForEach(self.selectedCategories.filter { $0.enabled }, id: \.id) {
          category in
          Chips(titleKey: LocalizedStringKey(category.data)).padding(5)
        }
      }
    }.padding().background(Rectangle().neuCard()).onAppear {
      self.selectedCategories = self.fact.categoryLabels!.map { DataState<String>(enabled: true, data: $0) }
    }
  }
}
