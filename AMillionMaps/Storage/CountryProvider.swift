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
import SQLite

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

class SQLCountryProvider: CountryProvider {
  var db: Connection?
  
  init () {
    guard let url = Bundle.main.url(forResource: "countries", withExtension: "db") else {
      fatalError("Failed to locate 'countries.db' in bundle.")
    }
    
    self.db = try? Connection(url.absoluteString)
  }
  
  
  func countries(_ filter: Filter) -> [Country] {
    switch filter.conjunctions.first?.conditions.first?.value {
    case let .numeric(value):
      if let db = db {
        var result: [Country] = []
        if let cursor = try? db.prepare("SELECT country_id FROM country WHERE country_population > \(value.lowerBound) AND country_population < \(value.upperBound)") {
          for row in cursor {
            result.append(Country(id: row[0] as! String))
          }
          print(result)
        }
        print(result)
        return result
      }
    default:
      print("not matched")
    }
    return [
      Country(id: "AFG"),
      Country(id: "ALB")
    ]
  }
  
  
  func factMetadata(fact: Fact) -> NumericMetadata {
    switch fact.type {
    case .Constant(.numeric):
      return NumericMetadata(range: 0...20000000000)
    case .TimeSeries(.numeric):
      return NumericMetadata(range: 0...10)
    default:
      fatalError("Metadata type \(NumericMetadata.self) does not match fact type \(fact.type)")
    }
  }
}


class DummyCountryProvider: CountryProvider {
  
  func countries(_ filter: Filter) -> [Country] {
    switch filter.conjunctions.first?.conditions.first?.value {
    case let .numeric(value):
      if value.lowerBound > 5 {
        return [
          Country(id: "AFG")
        ]
      }
    default:
      print("not matched")
    }
    return [
      Country(id: "AFG"),
      Country(id: "ALB")
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
