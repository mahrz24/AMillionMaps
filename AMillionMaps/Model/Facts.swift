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
  associatedtype ValueType
  associatedtype CollectionType
  
  var type: FactType { get }
  var id: String { get }
  var keyPath: PartialKeyPath<Country> { get }
  
}

extension Fact {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}


private class AbstractFact: Fact {
  var type: FactType { fatalError("To be implemented") }
  
  var id: String { fatalError("To be implemented") }
  
  var keyPath: PartialKeyPath<Country> { fatalError("To be implemented") }
  
  static func == (lhs: AbstractFact, rhs: AbstractFact) -> Bool {
    lhs.id == rhs.id
  }
  
  typealias ValueType = Any
  typealias CollectionType = Any
}


private final class FactWrapper<H: Fact>: AbstractFact {
    var fact: H
    
    init(with fact: H) {
        self.fact = fact
    }
    
  override var type: FactType { fact.type }
  override var id: String { fact.id }
  override var keyPath: PartialKeyPath<Country> { fact.keyPath }
}

struct AnyFact: Fact {
    static func == (lhs: AnyFact, rhs: AnyFact) -> Bool {
      lhs.id == rhs.id
    }
    
    public typealias ValueType = Any
    public typealias CollectionType = Any

    private var abstractFact: AbstractFact
    
    init<H: Fact>(with fact: H) {
        self.abstractFact = FactWrapper<H>(with: fact)
    }
  
    func unwrap<H : Fact>() -> H {
      return (self.abstractFact as! FactWrapper<H>).fact
    }
  
   var type: FactType { abstractFact.type }
   var id: String { abstractFact.id }
   var keyPath: PartialKeyPath<Country> { abstractFact.keyPath }
}

struct ConstantNumericFact : Fact {
  let distributeByRank: Bool
  let round: Int?
  
  static func == (lhs: ConstantNumericFact, rhs: ConstantNumericFact) -> Bool {
    lhs.id == rhs.id
  }
  
  var type: FactType
  var id: String
  var keyPath: PartialKeyPath<Country>
  
  
  public typealias ValueType = Double
  public typealias CollectionType = Double
}

protocol FactMetadata {
  
}

private class AbstractFactMetadata: FactMetadata {
  
}


private final class FactMetadataWrapper<H: FactMetadata>: AbstractFactMetadata {
    var factMetadata: H
    
    init(with factMetadata: H) {
        self.factMetadata = factMetadata
    }
    
  
}

struct AnyFactMetadata: FactMetadata {
    private var abstractFactMetadata: AbstractFactMetadata
    
    init<H: FactMetadata>(with factMetadata: H) {
        self.abstractFactMetadata = FactMetadataWrapper<H>(with: factMetadata)
    }
  
  func unwrap<H : FactMetadata>() -> H {
    return (self.abstractFactMetadata as! FactMetadataWrapper<H>).factMetadata
  }
}

struct NumericMetadata: FactMetadata {
  let range: ClosedRange<Double>
}
