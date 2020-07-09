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
  var db: Connection
  
  init (db: Connection) {
    self.db = db
  }
  
  fileprivate func toSQLCondition(_ condition: Condition) -> String {
    let fact = condition.fact
    switch fact.type {
    case .Constant(.numeric):
      let db_column = "country_\(fact.id.lowercased())"
      guard case let ConditionValue.numeric(value, lowerOpen, _) = condition.value else {
        fatalError("Condition fact type \(fact.type) and condition value \(condition.value) are not matching.")
      }
      
      var condition: String = ""
      
      if !lowerOpen {
        condition += "\(db_column) >= \(value.lowerBound) AND"
      } else {
        condition += "\(db_column) IS NULL OR"
      }
      
      condition += " \(db_column) <= \(value.upperBound)"
    
      return "(\(condition))" 
    default:
      fatalError("Condition of fact type \(fact.type) cannot be converted")
    }
  }
  
  func countries(_ filter: Filter) -> [Country] {
    let facts = Array(Set(Country.tableFacts + Country.mapFacts)).sorted(by: { $0.id < $1.id})
    let fact_columns = facts.map {
      "country_\($0.id.lowercased())"
    }
    
    let columns = ["country_id"] + Array(fact_columns)
    let columns_expression = columns.joined(separator: ", ")
    
    var condition = filter.conjunctions.map {
      conjunction in
      let conjunctionString = conjunction.conditions.filter {$0.value != ConditionValue.none}.map(toSQLCondition).joined(separator: " AND ")
      if conjunctionString.count > 0 {
        return "(" + conjunctionString + ")"
      }
      else
      {
        return ""
      }
    }.joined(separator: " OR ")
    
    var result: [Country] = []
    
    if condition.count > 0 {
      condition = " WHERE " + condition
    }
    
    let query = "SELECT \(columns_expression) FROM country \(condition)"
    
    print(query)
    
    if let cursor = try? db.prepare(query) {
      for row in cursor {
        result.append(Country(id: row[0] as! String))
      }
    }
    return result
  }
  
  
  fileprivate func asDouble(_ binding: Binding?) -> Double {
    guard let binding = binding else {
      return 0
    }
    switch binding {
    case let double as Double:
      return double
      
    case let int as Int64:
      return Double(int)
      
    default:
      return 0
    }
  }
  
  func factMetadata(fact: Fact) -> NumericMetadata {
    switch fact.type {
    case .Constant(.numeric):
      let db_column = "country_\(fact.id.lowercased())"
      
      print("SELECT MIN(\(db_column)), MAX(\(db_column)) FROM country")
      
      guard let statement = try? db.prepare("SELECT MIN(\(db_column)), MAX(\(db_column)) FROM country LIMIT 1") else {
        fatalError("Could not retrieve range for fact '\(fact.id)'")
      }
      
      guard let row = statement.next() else {
        fatalError("Could not retrieve range for fact '\(fact.id)'")
      }
      
      let lowerBound = asDouble(row[0])
      let upperBound = asDouble(row[1])
      
      print(lowerBound)
      print(upperBound)

      return NumericMetadata(range: lowerBound...upperBound)
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
    case let .numeric(value, _, _):
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
