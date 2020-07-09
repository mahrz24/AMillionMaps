//
//  Facts.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

struct NumericFactProperties {
  let logarithmicScale: Bool
  let round: Optional<Int>
}

enum FactType {
  case Constant(FactAtom)
  case TimeSeries(FactAtom)
}

enum FactAtom {
  case numeric(NumericFactProperties)
  case bool
  case categorical
}


struct Fact: Identifiable, Equatable, Hashable {
  static func == (lhs: Fact, rhs: Fact) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
      hasher.combine(id)
  }
  
  let type: FactType
  let id: String
  let keyPath: AnyKeyPath
}


struct NumericMetadata {
  let range: ClosedRange<Double>
}


