//
//  Country.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

class Country: Identifiable, Hashable {
  var id: String

  init(id: String) {
    self.id = id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Country, rhs: Country) -> Bool {
    lhs.id == rhs.id
  }

  static let facts: [AnyFact] = [
    AnyFact(with: ConstantNumericFact(distributeByRank: true, round: 0, unit: nil,
                                      id: "Population",
                                      keyPath: \Country.population,
                                      columnAttribues: ColumnAttributes(width: 200))),
    AnyFact(with: ConstantNumericFact(distributeByRank: false, round: 0, unit: "km²",
                                      id: "Area",
                                      keyPath: \Country.area,
                                      columnAttribues: ColumnAttributes(width: 200))),
    AnyFact(with: ConstantCategoricalFact(categoryLabels: [
        "Sovereign",
      "Country",
      "Dependency",
      "Other",
    ],
                                          id: "Type",
                                          keyPath: \Country.type,
                                          columnAttribues: ColumnAttributes(width: 200))),
  ]

  static var filterFacts: [AnyFact] {
    facts
  }

  static var mapFacts: [AnyFact] {
    facts
  }

  static var tableFacts: [AnyFact] {
    facts
  }

  var type: DomainValue?
  var population: DomainValue?
  var area: DomainValue?
}
