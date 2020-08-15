//
//  LegendView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 15.08.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI
import Resolver

struct LegendView: View {
  @ObservedObject var colorViewModel: ColorAndDataState = Resolver.resolve()
  
  func buildLegend(_ fact: AnyFact) -> some View {
    switch fact.type {
    case .Constant(.numeric):
      let numericFact: ConstantNumericFact = fact.unwrap()!
      
      let domainMapper = colorViewModel.domainMapperFactory.createDomainMapper(fact)
      
      
      
      return Text("numeric fact")
    default:
      return Text("No fact")
    }
    
  }
  
    var body: some View {
      if let fact = colorViewModel.fact {
        return AnyView(buildLegend(fact))
      } else {
        return AnyView(Text("No fact"))
      }
    }
}

struct LegendView_Previews: PreviewProvider {
    static var previews: some View {
        LegendView()
    }
}
