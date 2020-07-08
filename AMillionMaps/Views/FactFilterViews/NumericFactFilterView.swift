//
//  NumericFactView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 03.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI
import Sliders
import Resolver
import Combine


struct NumericFactFilterView: View {
  var fact: Fact
  var action: (ConditionValue) -> Void
  @Injected var countryProvider: CountryProvider
  @State private var filterRange: ClosedRange<Double> = 0...1
  @State private var filterBounds: ClosedRange<Double> = 0...1
  
    var body: some View {
      
      return VStack {
        HStack{
          Text(fact.id).font(.subheadline)
          Spacer()
        }
        RangeSlider(range: $filterRange, in: filterBounds, onEditingChanged: { _ in self.action(ConditionValue.numeric(self.filterRange)) })
          .frame(height: 15)
          .rangeSliderStyle(
           HorizontalRangeSliderStyle(
               track:
                   HorizontalRangeTrack(
                       view: LinearGradient(gradient: Gradient(colors: [.gray, .blue]), startPoint: .leading, endPoint: .trailing),
                       mask: Rectangle()
                   )
                    .frame(height:15)
                   .background(Color.secondary.opacity(0.25))
                   .cornerRadius(5),
               lowerThumb: Capsule().foregroundColor(.white).shadow(radius: 3),
               upperThumb: Capsule().foregroundColor(.white).shadow(radius: 3),
               lowerThumbSize: CGSize(width: 5, height: 15),
               upperThumbSize: CGSize(width: 5, height: 15)
           )
        )
      }.onAppear {
  
        let numericFactMetadata: NumericMetadata = self.countryProvider.factMetadata(fact: self.fact)
        self.filterRange = numericFactMetadata.range
        self.filterBounds = numericFactMetadata.range
      }
    }
}

//struct NumericFactView_Previews: PreviewProvider {
//    static var previews: some View {
//        NumericFactView(Fact()
//    }
//}
