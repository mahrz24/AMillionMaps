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


class FilterState: ObservableObject {
  @Injected var countryProvider: CountryProvider
  
  var countriesDidChange = PassthroughSubject<Void, Never>()

  
  @Published var filter: Filter = Filter() {
    didSet {
      self.updateFilteredCountries()
    }
  }

  var countries: [Country] = []

  init() {
    countries = countryProvider.countries(filter)
  }

  func updateFilteredCountries() {
    countries = countryProvider.countries(self.filter)
    countriesDidChange.send()
  }
}
