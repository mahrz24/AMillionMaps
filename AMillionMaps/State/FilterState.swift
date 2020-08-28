//
//  FilterState.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 11.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Combine
import Foundation
import Resolver
import SQLite
import SwiftUI

class FilterState: ObservableObject {
  @Injected var countryProvider: CountryProvider

  var countriesDidChange = PassthroughSubject<Void, Never>()

  @Published var filter: Filter = Filter() {
    didSet {
      updateFilteredCountries()
    }
  }

  var countries: [Country] = []

  init() {
    countries = countryProvider.countries(filter)
  }

  func updateFilteredCountries() {
    countries = countryProvider.countries(filter)
    countriesDidChange.send()
  }
}

class FilterSelectionState: ObservableObject {
  @ObservedObject var filterState: FilterState = Resolver.resolve()

  @Published var filters: [AnyFact: Condition] = [:] {
    didSet {
      filterState.filter = Filter(conjunctions: [Conjunction(conditions: Array(filters.values))])
    }
  }

  @Published var factStates: [DataState<AnyFact>] = Country.filterFacts.map {
    data in
    print("Reset")
    return DataState<AnyFact>(enabled: false, data: data)
  }
}
