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
      let domainMapper = colorViewModel.domainMapperFactory.createDomainMapper(fact)
      
      let images = Array<Double>(stride(from: 0.0, to: 1.0, by: 0.1))
      
      return AnyView(
        VStack{
        ForEach(images, id:\.hashValue) {
        image -> AnyView in
          if case let .Numeric(domain) = domainMapper.imageToDomain(.Numeric(image)) {
            return AnyView(HStack{
              Rectangle().foregroundColor(self.colorViewModel.colorTheme.colorForImageValue(image: .Numeric(image))).frame(width: 16, height: 16)
              Text("\(domain)")
            })
          } else {
            return AnyView(Text("No fact"))
          }
          }
      }
      )
    default:
      return AnyView(Text("No fact"))
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
