//
//  FilterView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI

struct FilterView: View {
  @Injected var countryProvider: CountryProvider

  @ObservedObject var selectionViewModel: SelectionViewState = Resolver.resolve()
  @ObservedObject var viewModel: FilterSelectionState = Resolver.resolve()

  func generateRow(factState: DataState<AnyFact>) -> AnyView {
    if factState.enabled {
      return AnyView(HStack {
        FactFilterView(fact: factState.data,
                       action: { self.viewModel.filters[factState.data] = Condition(fact: factState.data, value: $0) }).padding(17)
      })
    } else {
      return AnyView(EmptyView())
    }
  }

  var body: some View {
    VStack {
      HStack {
        Text("Filters").font(.title)
        Spacer()
      }
      ScrollView {
        VStack {
          HStack {
            Spacer()
          }
          ForEach(self.viewModel.factStates, id: \.id) {
            factState in self.generateRow(factState: factState)
          }
          HStack {
            SidePanelButton(panelBuilder: {
              MultiListPicker(self.$viewModel.factStates) {
                fact, selected in Checkbox(selected: selected, label: fact.id)
              }
            }

            ) {
              Text("Edit")
            }
          }
        }
      }
    }
  }
}

//
// struct FilterView_Previews: PreviewProvider {
//  static var previews: some View {
//    FilterView(selectorViewState: .constant(SelectorViewState.hidden)).previewLayout(PreviewLayout.fixed(width: 250, height: 400))
//      .padding()
//      .previewDisplayName("Default preview")
//  }
// }
