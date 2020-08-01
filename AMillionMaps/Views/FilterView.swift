//
//  FilterView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI

class FilterViewModel: ObservableObject {
  @ObservedObject var filterState: FilterState = Resolver.resolve()

  @Published var filters: [AnyFact: Condition] = [:] {
    didSet {
      filterState.filter = Filter(conjunctions: [Conjunction(conditions: Array(filters.values))])
    }
  }

  @Published var factStates: [FactState] = Country.filterFacts.map { FactState(enabled: false, fact: $0) }
}

struct FilterView: View {
  @Injected var countryProvider: CountryProvider

  @Binding var selectorViewState: SelectorViewState
  @ObservedObject var viewModel: FilterViewModel

  func generateRow(factState: FactState) -> AnyView {
    if factState.enabled {
      return AnyView(HStack {
        FactFilterView(fact: factState.fact,
                       action: { self.viewModel.filters[AnyFact(with: factState.fact)] = Condition(fact: factState.fact, value: $0) })
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
          ForEach(self.viewModel.factStates, id: \.self) {
            factState in self.generateRow(factState: factState)
          }
          HStack {
            Button(action: { self.selectorViewState = .filterFactSelection }) {
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
