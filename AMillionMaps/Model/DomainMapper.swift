//
//  DomainMapper.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 16.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import Resolver

enum DomainValue {
  case Numeric(Double)
  case Categorical(String)
}

enum ImageValue {
  case Numeric(Double)
  case Categorical(Int)
}

protocol DomainMapper {
  func domainToImage(_ domain: DomainValue) -> ImageValue
}

private class AbstractDomainMapper: DomainMapper {
  typealias DomainValueType = Any

  func domainToImage(_: DomainValue) -> ImageValue {
    fatalError("Must implement")
  }
}

private final class DomainMapperWrapper<H: DomainMapper>: AbstractDomainMapper {
  var domainMapper: H

  init(with domainMapper: H) {
    self.domainMapper = domainMapper
  }

  override func domainToImage(_ domain: DomainValue) -> ImageValue {
    domainMapper.domainToImage(domain)
  }
}

struct AnyDomainMapper: DomainMapper {
  public func domainToImage(_ domain: DomainValue) -> ImageValue {
    abstractDomainMapper.domainToImage(domain)
  }

  private var abstractDomainMapper: AbstractDomainMapper

  init<H: DomainMapper>(with domainMapper: H) {
    abstractDomainMapper = DomainMapperWrapper<H>(with: domainMapper)
  }
}

protocol DomainMapperFactory: Identifiable {
  var id: String { get }
  func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper
}

private class AbstractDomainMapperFactory: DomainMapperFactory {
  var id: String {
    fatalError("Must implement")
  }

  func createDomainMapper(_: AnyFact) -> AnyDomainMapper {
    fatalError("Must implement")
  }
}

private final class DomainMapperFactoryWrapper<H: DomainMapperFactory>: AbstractDomainMapperFactory {
  var domainMapperFactory: H

  public init(with domainMapperFactory: H) {
    self.domainMapperFactory = domainMapperFactory
  }

  override var id: String {
    self.domainMapperFactory.id
  }

  override func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper {
    domainMapperFactory.createDomainMapper(fact)
  }
}

public struct AnyDomainMapperFactory: DomainMapperFactory {
  fileprivate let abstractDomainMapperFactory: AbstractDomainMapperFactory

  init<H: DomainMapperFactory>(with domainMapperFactory: H) {
    abstractDomainMapperFactory = DomainMapperFactoryWrapper(with: domainMapperFactory)
  }

  public var id: String {
    abstractDomainMapperFactory.id
  }

  func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper {
    abstractDomainMapperFactory.createDomainMapper(fact)
  }
}

struct LinearDomainMapperFactory: DomainMapperFactory {
  var id: String = "Linear"

  @Injected var filterState: FilterState
  @Injected var countryProvider: CountryProvider

  func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper {
    let meta = countryProvider.factMetadata(fact, filter: filterState.filter)
    if let meta: NumericMetadata = meta.unwrap() {
      return AnyDomainMapper(with: LinearDomainMapper(meta: meta))
    }
    return AnyDomainMapper(with: NullDomainMapper())
  }
}

struct LinearDomainMapper: DomainMapper {
  var meta: NumericMetadata

  func domainToImage(_ domain: DomainValue) -> ImageValue {
    switch domain {
    case let .Numeric(domain):
      return .Numeric((domain - meta.range.lowerBound) / (meta.range.upperBound - meta.range.lowerBound))
    default:
      return .Numeric(0)
    }
  }
}

struct RankDomainMapperFactory: DomainMapperFactory {
  var id: String = "Rank"

  @Injected var filterState: FilterState
  @Injected var countryProvider: CountryProvider

  func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper {
    if let fact: ConstantNumericFact = fact.unwrap() {
      let rank = countryProvider.factRank(fact, filter: filterState.filter)
      return AnyDomainMapper(with: RankDomainMapper(rank: rank))
    }
    return AnyDomainMapper(with: NullDomainMapper())
  }
}

struct RankDomainMapper: DomainMapper {
  var rank: [(String, Double)]
  func domainToImage(_ domain: DomainValue) -> ImageValue {
    switch domain {
    case let .Numeric(domain):
      let index = rank.map { $0.1 }.firstIndex { $0 > domain } ?? rank.count - 1
      return .Numeric(Double(index) / Double(rank.count - 1))
    default:
      return .Numeric(0)
    }
  }
}

struct CategoricalDomainMapperFactory: DomainMapperFactory {
  var id: String = "Categorical"

  @Injected var filterState: FilterState
  @Injected var countryProvider: CountryProvider

  func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper {
    // TODO: could be a fact with dynamic categoricals
    if let categoricalFact: ConstantCategoricalFact = fact.unwrap() {
      return AnyDomainMapper(with: CategoricalDomainMapper(categories: categoricalFact.categoryLabels!))
    }
    return AnyDomainMapper(with: NullDomainMapper())
  }
}

struct CategoricalDomainMapper: DomainMapper {
  var categories: [String]
  func domainToImage(_ domain: DomainValue) -> ImageValue {
    switch domain {
    case let .Categorical(domain):
      let index = categories.firstIndex(of: domain) ?? 0
      return .Categorical(index)
    default:
      return .Categorical(0)
    }
  }
}

struct NullDomainMapper: DomainMapper {
  func domainToImage(_: DomainValue) -> ImageValue {
    .Numeric(0)
  }
}

//
// struct QuantizedDomainMapper: DomainMapper {
//  func domainToImage(_ domain: Double) -> Double {
//    return 0
//  }
// }
//
