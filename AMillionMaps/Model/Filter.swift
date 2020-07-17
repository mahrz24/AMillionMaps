//
//  Filter.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

enum ConditionValue: Equatable {
  case numeric(ClosedRange<Double>, Bool, Bool)
  case categorical([String])
  case bool(Bool)
  case none
}

struct Filter: Equatable {
  var conjunctions: [Conjunction] = []
}

struct Conjunction: Equatable {
  var conditions: [Condition] = []
}

struct Condition: Equatable {
  static func == (lhs: Condition, rhs: Condition) -> Bool {
    return lhs.fact == rhs.fact && lhs.value == rhs.value
  }

  var fact: Fact
  var value: ConditionValue
}
