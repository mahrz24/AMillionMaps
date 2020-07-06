//
//  CountryProvider.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import Resolver
import Combine

protocol CountryProvider {
  func countries(_ filter: Filter) -> [Country]
  func factMetadata(fact: Fact) -> NumericMetadata
}

protocol StatefulFilteredCountryProvider {
  var countriesDidChange: PassthroughSubject<Void, Never> { get }
  var countries: [Country] { get }
  func apply(_ filter: Filter)
}

class DefaultStatefulFilteredCountryProvider:  StatefulFilteredCountryProvider {
  private var filter: Filter = Filter()
  @Injected var countryProvider: CountryProvider
  
  var countriesDidChange = PassthroughSubject<Void, Never>()
  
  var countries: [Country] = [] {
    didSet {
      print("Countries set")
      countriesDidChange.send()
    }
  }
  
  init() {
    self.countries = countryProvider.countries(self.filter)
  }
  
  func apply(_ filter: Filter) {
    if filter != self.filter {
      self.filter = filter
      self.countries = countryProvider.countries(self.filter)
    }
  }
  
  
  
  
}

class DummyCountryProvider: CountryProvider {
  
  func countries(_ filter: Filter) -> [Country] {
    switch filter.conjunctions.first?.conditions.first?.value {
    case let .numeric(value):
      if value.lowerBound > 5 {
        return [
          Country(id: ISO3166_1_Alpha3CountryCode.AFG, iSO3166_1_Alpha3CountryCode: "AFG")
        ]
      }
    default:
      print("not matched")
    }
    return [
      Country(id: ISO3166_1_Alpha3CountryCode.AFG, iSO3166_1_Alpha3CountryCode: "AFG"),
      Country(id: ISO3166_1_Alpha3CountryCode.ALB, iSO3166_1_Alpha3CountryCode: "ALB")
    ]
  }
  
  
  func factMetadata(fact: Fact) -> NumericMetadata {
    switch fact.type {
    case .Constant(.numeric):
      return NumericMetadata(range: 0...10)
    case .TimeSeries(.numeric):
      return NumericMetadata(range: 0...10)
    default:
      fatalError("Metadata type \(NumericMetadata.self) does not match fact type \(fact.type)")
    }
  }
  
  
}
