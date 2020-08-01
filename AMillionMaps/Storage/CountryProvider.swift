//
//  CountryProvider.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Combine
import Foundation
import Resolver
import SQLite

protocol CountryProvider {
  func countries(_ filter: Filter) -> [Country]
  func countryIds(_ filter: Filter) -> [String]

  func factMetadata(_ fact: AnyFact, filter: Filter) -> AnyFactMetadata
  func factRank(_ fact: ConstantNumericFact, filter: Filter) -> [(String, Double)]

  func factMetadata(_ fact: AnyFact) -> AnyFactMetadata
  func factRank(_ fact: ConstantNumericFact) -> [(String, Double)]
}

class SQLCountryProvider: CountryProvider {
  var db: Connection

  private var countryCache: [String: Country] = [:]
  private var rankCache: [ConstantNumericFact: [(String, Double)]] = [:]

  init(db: Connection) {
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

  func countryIds(_ filter: Filter) -> [String] {
    var condition = filter.conjunctions.map {
      conjunction in
      let conjunctionString = conjunction.conditions.filter { $0.value != ConditionValue.none }.map(toSQLCondition)
        .joined(separator: " AND ")
      if conjunctionString.count > 0 {
        return "(" + conjunctionString + ")"
      } else {
        return ""
      }
    }.joined(separator: " OR ")

    if condition.count > 0 {
      condition = " WHERE " + condition
    }

    let query = "SELECT country_id FROM country \(condition)"

    var result: [String] = []

    if let cursor = try? db.prepare(query) {
      for row in cursor {
        result.append(row[0] as! String)
      }
    }
    return result
  }

  func countries(_ filter: Filter) -> [Country] {
    let ids = countryIds(filter)

    return ids.map(countryForId).map { $0! }
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

  func countryForId(id: String) -> Country? {
    if countryCache.keys.contains(id) {
      return countryCache[id]
    }

    let facts = Array(Set(Country.tableFacts + Country.mapFacts)).sorted(by: { $0.id < $1.id })
    let fact_columns = facts.map {
      "country_\($0.id.lowercased())"
    }
    let columns = ["country_id"] + Array(fact_columns)
    let columns_expression = columns.joined(separator: ", ")

    let query = "SELECT \(columns_expression) FROM country WHERE country_id = '\(id)'"

    var country_ids: [String] = []

    if let cursor = try? db.prepare(query) {
      if let row = cursor.next() {
        var country = Country(id: row[0] as! String)

        for (i, fact) in facts.enumerated() {
          switch fact.type {
          case .Constant(.numeric):
            let numericFact: ConstantNumericFact = fact.unwrap()!
            let keyPath = numericFact.keyPath as! WritableKeyPath<Country, DomainValue?>
            if let value = row[i + 1] {
              country[keyPath: keyPath] = DomainValue.Numeric(value as! Double)
            }
          case .Constant(.categorical):
            let categoricalFact: ConstantCategoricalFact = fact.unwrap()!
            let keyPath = categoricalFact.keyPath as! WritableKeyPath<Country, DomainValue?>
            if let categoryLabels = categoricalFact.categoryLabels {
              if let idx = row[i + 1] as! Double? {
                country[keyPath: keyPath] = DomainValue.Categorical(categoryLabels[Int(idx)])
              }
            } else {
              if let category = row[i + 1] {
                country[keyPath: keyPath] = DomainValue.Categorical(category as! String)
              }
            }
          default:
            print("Not matched \(fact.id)")
          }
        }

        countryCache[id] = country

        return country
      }
      for row in cursor {
        country_ids.append(row[0] as! String)
      }
    }
    return nil
  }

  func factMetadata(_ fact: AnyFact, filter: Filter) -> AnyFactMetadata {
    // TODO: make the fact provide the metadata using the provider
    switch fact.type {
    case .Constant(.numeric):
      let numericFact: ConstantNumericFact = fact.unwrap()!
      let factValues = factRank(numericFact, filter: filter).map { $0.1 }
      let minValue = factValues.min() ?? 0
      let maxValue = factValues.max() ?? 1

      return AnyFactMetadata(with: NumericMetadata(range: minValue ... maxValue))
    case .Constant(.categorical):
      return AnyFactMetadata(with: CategoricalMetadata())
    default:
      return AnyFactMetadata(with: NumericMetadata(range: 0 ... 1))
    }
  }

  func factMetadata(_ fact: AnyFact) -> AnyFactMetadata {
    switch fact.type {
    case .Constant(.numeric):
      let numericFact: ConstantNumericFact = fact.unwrap()!
      let factValues = factRank(numericFact).map { $0.1 }
      let minValue = factValues.min() ?? 0
      let maxValue = factValues.max() ?? 1

      return AnyFactMetadata(with: NumericMetadata(range: minValue ... maxValue))
    default:
      return AnyFactMetadata(with: NumericMetadata(range: 0 ... 1))
    }
  }

  func factRank(_ fact: ConstantNumericFact, filter: Filter) -> [(String, Double)] {
    let ids = countryIds(filter)
    let rank = factRank(fact)

    return rank.filter { ids.contains($0.0) }
  }

  func factRank(_ fact: ConstantNumericFact) -> [(String, Double)] {
    if rankCache.keys.contains(fact) {
      return rankCache[fact] ?? []
    }

    let db_column = "country_\(fact.id.lowercased())"

    guard let statement = try? db
      .prepare("SELECT country_id, \(db_column) FROM country WHERE \(db_column) NOT NULL ORDER BY \(db_column) ASC") else {
      fatalError("Could not retrieve ranks for fact '\(fact.id)'")
    }

    var result: [(String, Double)] = []
    for row in statement {
      result.append((row[0] as! String, row[1] as! Double))
    }

    rankCache[fact] = result

    return result
  }
}
