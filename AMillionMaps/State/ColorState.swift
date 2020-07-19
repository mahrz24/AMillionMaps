//
//  ColorState.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 11.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Combine
import Foundation
import UIKit
import Resolver


class ColorAndDataState: ObservableObject {
  
  @Injected var countryProvider: CountryProvider
  @Injected var filterState: FilterState
  
  @Published var countryColors: [String : UIColor] = [:]
  
  @Published var domainMapperFactory: AnyDomainMapperFactory = AnyDomainMapperFactory(with: LinearDomainMapperFactory()) {
    didSet {
      updateCountryColors()
    }
  }
  
  @Published var showFiltered: Bool = true {
    didSet {
      // showing filtered or not does not change the country color mapping
      stateDidChange.send()
    }
  }
  
  @Published var colorTheme: ColorTheme = ColorTheme.makeDefaultTheme() {
    didSet {
      updateCountryColors()
    }
  }
  
  @Published  var fact: Fact? {
    didSet {
      updateCountryColors()
    }
  }
    
  var stateDidChange = PassthroughSubject<Void, Never>()
  var filterChanged: AnyCancellable?
  
  init () {
    filterChanged = filterState.countriesDidChange.debounce(for: .milliseconds(50), scheduler: RunLoop.main).sink {
      self.updateCountryColors()
    }
  }
  
  func updateCountryColors() {
    if let fact = fact {
      let keyPath = fact.keyPath as! KeyPath<Country, Double?>
      
      let meta = countryProvider.factMetadata(fact)
      let values = countryProvider.countries(Filter(conjunctions: [])).map { ($0.id, $0[keyPath: keyPath] ?? meta.range.lowerBound)  }
      let mapping = values.reduce(into: [:]) { $0[$1.0] = ($1.1 ) }
      
      let domainMapper = domainMapperFactory.createDomainMapper(fact)
      
      let normalizedValues = mapping.mapValues({ domainMapper.domainToImage($0) })
      self.countryColors = normalizedValues.mapValues(colorTheme.colorForImageValue)
    } else {
      self.countryColors = [:]
    }
    
    stateDidChange.send()
  }
}
