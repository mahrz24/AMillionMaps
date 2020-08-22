//
//  LegendView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 15.08.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI

struct LegendView: View {
  @ObservedObject var colorViewModel: ColorAndDataState = Resolver.resolve()

  func buildLegend(_ fact: AnyFact) -> some View {
    let domainMapper = colorViewModel.domainMapperFactory.createDomainMapper(fact)

    var images: [ImageValue] = []

    switch fact.type {
    case .Constant(.numeric):
      images = stride(from: 0.0, through: 1.0, by: 0.1).map(ImageValue.Numeric)
    case .Constant(.categorical):
      let md: CategoricalMetadata = colorViewModel.countryProvider.factMetadata(fact).unwrap()!

      images = md.range.map(ImageValue.Categorical)
    default:
      ()
    }

    return VStack(alignment: .trailing) {
      ForEach(images, id: \.self) {
        image -> AnyView in
        let domainValue = domainMapper.imageToDomain(image)
        return AnyView(HStack {
          Text("\(fact.format(domainValue)?.value ?? "N/A")")
          Rectangle().foregroundColor(self.colorViewModel.colorTheme.colorForImageValue(image: image))
            .frame(width: 16, height: 16)
          })
      }
    }.padding(10)
  }

  func legendView() -> AnyView {
    if let fact = colorViewModel.fact {
      return AnyView(
        buildLegend(fact).background(BlurView(style: .light).cornerRadius(5))
      )
    } else {
      return AnyView(EmptyView())
    }
  }

  var body: some View {
    self.legendView()
  }
}

struct LegendView_Previews: PreviewProvider {
  static var previews: some View {
    LegendView()
  }
}
