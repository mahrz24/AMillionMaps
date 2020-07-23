//
//  DomainMapper.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 16.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import Resolver

protocol DomainMapper {
  associatedtype DomainType
  func domainToImage(_ domain: DomainType) -> Double
}

private class AbstractDomainMapper: DomainMapper {
    typealias DomainType = Any
    
    func domainToImage(_ domain: AbstractDomainMapper.DomainType) -> Double {
        fatalError("Must implement")
    }
}

private final class DomainMapperWrapper<H: DomainMapper>: AbstractDomainMapper {
    var domainMapper: H
    
    init(with domainMapper: H) {
        self.domainMapper = domainMapper
    }
    
    override func domainToImage(_ domain: AbstractDomainMapper.DomainType) -> Double {
        let typedDomain = domain as! H.DomainType
        return domainMapper.domainToImage(typedDomain)
    }
}

struct AnyDomainMapper: DomainMapper {
    public func domainToImage(_ domain: Any) -> Double {
        self.abstractDomainMapper.domainToImage(domain)
    }
    
    public typealias DomainType = Any

    private var abstractDomainMapper: AbstractDomainMapper
    
    init<H: DomainMapper>(with domainMapper: H) {
        self.abstractDomainMapper = DomainMapperWrapper<H>(with: domainMapper)
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
    
  func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper {
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
    return self.domainMapperFactory.createDomainMapper(fact)
  }
}

public struct AnyDomainMapperFactory: DomainMapperFactory {
  fileprivate let abstractDomainMapperFactory: AbstractDomainMapperFactory

  init<H: DomainMapperFactory>(with domainMapperFactory: H) {
    abstractDomainMapperFactory = DomainMapperFactoryWrapper(with: domainMapperFactory)
  }
  
  public var id: String {
    self.abstractDomainMapperFactory.id
  }
  
  func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper {
    return self.abstractDomainMapperFactory.createDomainMapper(fact)
  }
}

struct LinearDomainMapperFactory: DomainMapperFactory {
  var id: String = "Linear"
  
  @Injected var filterState: FilterState
  @Injected var countryProvider: CountryProvider
  
  func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper {
    let meta = countryProvider.factMetadata(fact, filter: filterState.filter)
    return AnyDomainMapper(with: LinearDomainMapper(meta: meta.unwrap()))
  }
}

struct RankDomainMapperFactory: DomainMapperFactory {
  var id: String = "Rank"

  @Injected var filterState: FilterState
  @Injected var countryProvider: CountryProvider
  
  func createDomainMapper(_ fact: AnyFact) -> AnyDomainMapper {
    let rank = countryProvider.factRank(fact.unwrap(), filter: filterState.filter)
    return AnyDomainMapper(with: RankDomainMapper(rank: rank))
  }
}

struct LinearDomainMapper: DomainMapper {
  var meta: NumericMetadata
  
  func domainToImage(_ domain: Double) -> Double {
    return (domain - meta.range.lowerBound)/(meta.range.upperBound-meta.range.lowerBound)
  }
}

struct RankDomainMapper: DomainMapper {
  var rank: [(String, Double)]
  func domainToImage(_ domain: Double) -> Double {
    let index = rank.map { $0.1 }.firstIndex { $0 > domain } ?? rank.count - 1
    return Double(index) / Double(rank.count - 1)
  }
}

struct QuantizedDomainMapper: DomainMapper {
  func domainToImage(_ domain: Double) -> Double {
    return 0
  }
}

