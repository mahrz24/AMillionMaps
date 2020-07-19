//
//  Country.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

class Country: Identifiable {
  var id: String

  init(id: String) {
    self.id = id
  }

  static let facts: [Fact] = [
    Fact(type: FactType.Constant(.numeric(NumericFactProperties(distributeByRank: true, round: 0))),
         id: "Population",
         keyPath: \Country.population),
    Fact(type: FactType.Constant(.numeric(NumericFactProperties(distributeByRank: false, round: 2))),
         id: "Area",
         keyPath: \Country.area),
    Fact(type: FactType.Constant(.categorical(CategoricalFactProperties(categoryLabels: [
      "Sovereign",
      "Country",
      "Dependency",
      "Other"
    ]))),
        id: "Type",
        keyPath: \Country.type),
  ]

  static var filterFacts: [Fact] {
    facts
  }

  static var mapFacts: [Fact] {
    facts
  }

  static var tableFacts: [Fact] {
    facts
  }

  var type: Int?
  var population: Double?
  var area: Double?
}
