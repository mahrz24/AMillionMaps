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

  static let facts: [AnyFact] = [
    AnyFact(with: ConstantNumericFact(distributeByRank: true, round: 0, type: FactType.Constant(.numeric),
         id: "Population",
         keyPath: \Country.population)),
    AnyFact(with: ConstantNumericFact(distributeByRank: false, round: 0, type: FactType.Constant(.numeric),
         id: "Area",
         keyPath: \Country.area))
//    Fact(type: FactType.Constant(.categorical(CategoricalFactProperties(categoryLabels: [
//      "Sovereign",
//      "Country",
//      "Dependency",
//      "Other"
//    ]))
//      ),
//        id: "Type",
//        keyPath: \Country.type),
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

  var type: Int?
  var population: Double?
  var area: Double?
}
