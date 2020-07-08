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
    Fact(
      type: FactType.Constant(.numeric),
      id: "Population",
      keyPath: \Country.population
    ),
    Fact(
      type: FactType.Constant(.numeric),
      id: "Area",
      keyPath: \Country.area
    )
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
  
  var population: Double = 0
  var area: Double = 0
}
