//
//  ColorState.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 11.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Combine
import Foundation
import Resolver
import UIKit

func liftDomainMapper(_ f: @escaping ((DomainValue) -> ImageValue)) -> ((DomainValue?) -> ImageValue?) {
  return { value in
    if let value = value {
      return f(value)
    }
    return nil
  }
}

class ColorAndDataState: ObservableObject {
  @Injected var countryProvider: CountryProvider
  @Injected var filterState: FilterState

  @Published var countryColors: [String: UIColor] = [:]

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

  @Published var fact: AnyFact? {
    didSet {
      updateCountryColors()
    }
  }

  var stateDidChange = PassthroughSubject<Void, Never>()
  var filterChanged: AnyCancellable?

  init() {
    filterChanged = filterState.countriesDidChange.debounce(for: .milliseconds(50), scheduler: RunLoop.main).sink {
      self.updateCountryColors()
    }
  }

  func updateCountryColors() {
    if let fact = fact {
      let values = countryProvider.countries(Filter(conjunctions: [])).map { ($0.id, $0[keyPath: fact.keyPath]) }
      let mapping = values.reduce(into: [:]) { $0[$1.0] = $1.1 }

      let domainMapper = domainMapperFactory.createDomainMapper(fact)

      let normalizedValues = mapping.mapValues { liftDomainMapper(domainMapper.domainToImage)($0) }
      countryColors = normalizedValues.mapValues(colorTheme.colorForImageValue)
    } else {
      countryColors = [:]
    }

    stateDidChange.send()
  }
}
