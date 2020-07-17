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
  func domainToImage(_ domain: Double) -> Double
}

protocol DomainMapperFactory {
  func createDomainMapper(fact: Fact) -> DomainMapper
}

struct LinearDomainMapperFactory: DomainMapperFactory {
  @Injected var filterState: FilterState
  @Injected var countryProvider: CountryProvider
  
  func createDomainMapper(fact: Fact) -> DomainMapper {
    let meta = countryProvider.factMetadata(fact, filter: filterState.filter)
    return LinearDomainMapper(meta: meta)
  }
}

struct RankDomainMapperFactory: DomainMapperFactory {
  @Injected var filterState: FilterState
  @Injected var countryProvider: CountryProvider
  
  func createDomainMapper(fact: Fact) -> DomainMapper {
    let rank = countryProvider.factRank(fact, filter: filterState.filter)
    return RankDomainMapper(rank: rank)
  }
}

struct LinearDomainMapper: DomainMapper {
  var meta: NumericMetadata
  
  func domainToImage(_ domain: Double) -> Double {
    return (meta.range.upperBound - domain)/(meta.range.upperBound-meta.range.lowerBound)
  }
}

struct RankDomainMapper: DomainMapper {
  var rank: [(String, Double)]
  func domainToImage(_ domain: Double) -> Double {
    return 0
  }
}

struct QuantizedDomainMapper: DomainMapper {
  func domainToImage(_ domain: Double) -> Double {
    return 0
  }
}
