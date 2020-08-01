//
//  Facts.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

enum FactType {
  case Constant(FactAtom)
  case TimeSeries(FactAtom)
}

enum FactAtom {
  case numeric
  case bool
  case categorical
}

protocol Fact: Identifiable, Hashable {
  var type: FactType { get }
  var id: String { get }
  var keyPath: KeyPath<Country, DomainValue?> { get }
}

extension Fact {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

private class AbstractFact: Fact {
  var type: FactType { fatalError("To be implemented") }

  var id: String { fatalError("To be implemented") }

  var keyPath: KeyPath<Country, DomainValue?> { fatalError("To be implemented") }

  static func == (lhs: AbstractFact, rhs: AbstractFact) -> Bool {
    lhs.id == rhs.id
  }
}

private final class FactWrapper<H: Fact>: AbstractFact {
  var fact: H

  init(with fact: H) {
    self.fact = fact
  }

  override var type: FactType { fact.type }
  override var id: String { fact.id }
  override var keyPath: KeyPath<Country, DomainValue?> { fact.keyPath }
}

struct AnyFact: Fact {
  static func == (lhs: AnyFact, rhs: AnyFact) -> Bool {
    lhs.id == rhs.id
  }

  private var abstractFact: AbstractFact

  init<H: Fact>(with fact: H) {
    abstractFact = FactWrapper<H>(with: fact)
  }

  func unwrap<H: Fact>() -> H? {
    (abstractFact as? FactWrapper<H>)?.fact
  }

  var type: FactType { abstractFact.type }
  var id: String { abstractFact.id }
  var keyPath: KeyPath<Country, DomainValue?> { abstractFact.keyPath }
}

struct ConstantNumericFact: Fact {
  let distributeByRank: Bool
  let round: Int?

  static func == (lhs: ConstantNumericFact, rhs: ConstantNumericFact) -> Bool {
    lhs.id == rhs.id
  }

  let type: FactType = .Constant(.numeric)
  var id: String
  var keyPath: KeyPath<Country, DomainValue?>
}

struct ConstantCategoricalFact: Fact {
  let categoryLabels: [String]?

  static func == (lhs: ConstantCategoricalFact, rhs: ConstantCategoricalFact) -> Bool {
    lhs.id == rhs.id
  }

  let type: FactType = .Constant(.categorical)
  var id: String
  var keyPath: KeyPath<Country, DomainValue?>
}

protocol FactMetadata {}

private class AbstractFactMetadata: FactMetadata {}

private final class FactMetadataWrapper<H: FactMetadata>: AbstractFactMetadata {
  var factMetadata: H

  init(with factMetadata: H) {
    self.factMetadata = factMetadata
  }
}

struct AnyFactMetadata: FactMetadata {
  private var abstractFactMetadata: AbstractFactMetadata

  init<H: FactMetadata>(with factMetadata: H) {
    abstractFactMetadata = FactMetadataWrapper<H>(with: factMetadata)
  }

  func unwrap<H: FactMetadata>() -> H? {
    (abstractFactMetadata as? FactMetadataWrapper<H>)?.factMetadata
  }
}

struct NumericMetadata: FactMetadata {
  let range: ClosedRange<Double>
}

struct CategoricalMetadata: FactMetadata {}
