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

struct TickView: View {
  var ticks: [Double]
  
  init(ticks: [Double]) {
    self.ticks = ticks
  }
  
  var body: some View {
    ZStack{
      Rectangle().foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
      GeometryReader { geometry in
        Path { path in
          for tick in self.ticks {
            path.move(to: CGPoint(x: CGFloat(tick)*geometry.size.width, y: 1))
            path.addLine(to: CGPoint(x: CGFloat(tick)*geometry.size.width, y: geometry.size.height-1))
          }
        }
        .stroke(Color.gray, lineWidth: 1)
        
      }
    }
  }
}

struct NumericFactFilterView: View {
  var fact: Fact
  var action: (ConditionValue) -> Void
  @Injected var countryProvider: CountryProvider
  @State private var filterRange: ClosedRange<Double> = 0...1
  @State private var filterBounds: ClosedRange<Double> = 0...1
  @State private var factBounds: ClosedRange<Double> = 0...1

  
  private var isLogarithmic: Bool {
    get {
      guard case let FactType.Constant(FactAtom.numeric(props)) = fact.type else {
        fatalError("Fact type not matching fact filter view")
      }
      
      return props.logarithmicScale
    }
  }
  
  private var roundDigits: Optional<Int> {
    get {
      guard case let FactType.Constant(FactAtom.numeric(props)) = fact.type else {
        fatalError("Fact type not matching fact filter view")
      }
      
      return props.round
    }
  }
  
  var filterTicks: [Double] {
    get {
      let factBounds = self.toFactRange(filterBounds)
      
      let offset: Double = 1
            
      let range = factBounds.upperBound - factBounds.lowerBound
      let exponent = round(log(range)/log(10))-offset
      
      let step = pow(10, exponent)
      let lowerTick = ceil((factBounds.lowerBound) / step) * step
      let ticks = stride(from: lowerTick, to: factBounds.upperBound, by: step)
      
      if self.isLogarithmic {
        return ticks.map(toSliderValue).map(toViewCoordinate)
      }
      
      return ticks.map(toViewCoordinate)
    }
  }
  
  func toViewCoordinate(_ rangeCoordinate: Double) -> Double {
    return (rangeCoordinate - filterBounds.lowerBound) / (filterBounds.upperBound - filterBounds.lowerBound)
  }
  
  func toSliderRange(_ factRange: ClosedRange<Double>) -> ClosedRange<Double> {
    return toSliderValue(factRange.lowerBound)...toSliderValue(factRange.upperBound)
  }
  
  func toFactRange(_ sliderRange: ClosedRange<Double>) -> ClosedRange<Double> {
    return toFactValue(sliderRange.lowerBound)...toFactValue(sliderRange.upperBound)
  }
  
  func toFactValue(_ sliderValue: Double) -> Double {
    if self.isLogarithmic {
      return pow(10, sliderValue)
    } else {
      return sliderValue
    }
  }
  
  func toSliderValue(_ factValue: Double) -> Double {
    if self.isLogarithmic {
      return log(factValue)/log(10)
    } else {
      return factValue
    }
  }
    
    var body: some View {
      
      return VStack {
        HStack{
          Text(fact.id).font(.subheadline)
          Spacer()
        }
          VStack {
            RangeSlider(range: $filterRange, in: filterBounds, onEditingChanged: { _ in self.action(ConditionValue.numeric(self.toFactRange(self.filterRange), self.filterRange.lowerBound == self.filterBounds.lowerBound, self.filterRange.upperBound == self.filterBounds.upperBound)) })
          .frame(height: 15)
          .rangeSliderStyle(
           HorizontalRangeSliderStyle(
               track:
                   HorizontalRangeTrack(
                    view: TickView(ticks: self.filterTicks),
                       mask: Rectangle()
                   )
                    .frame(height:12)
                   .background(TickView(ticks: self.filterTicks).opacity(0.5))
                   .cornerRadius(5),
               lowerThumb: Capsule().foregroundColor(.white).shadow(radius: 3),
               upperThumb: Capsule().foregroundColor(.white).shadow(radius: 3),
               lowerThumbSize: CGSize(width: 5, height: 15),
               upperThumbSize: CGSize(width: 5, height: 15)
           )
            )
            HStack{
              Text(formatNumber(toFactValue(filterRange.lowerBound), truncate: self.roundDigits ?? 1)).font(.footnote)
              Spacer()
              Text(formatNumber(toFactValue(filterRange.upperBound), truncate: self.roundDigits ?? 1)).font(.footnote)
            }
          }
      
      }.onAppear {
  
        let numericFactMetadata: NumericMetadata = self.countryProvider.factMetadata(fact: self.fact)
        self.factBounds = numericFactMetadata.range
        self.filterRange = self.toSliderRange(numericFactMetadata.range)
        self.filterBounds = self.toSliderRange(numericFactMetadata.range)
      }
    }
}

struct NumericFactFilterView_Previews: PreviewProvider {
    static var previews: some View {
      VStack {
      NumericFactFilterView(fact: Fact(
        type: FactType.Constant(.numeric(NumericFactProperties(logarithmicScale: false, round: 0))),
        id: "Population",
        keyPath: \Country.population
      ), action: { _ in print("HI") })
        
        
        
        NumericFactFilterView(fact: Fact(
          type: FactType.Constant(.numeric(NumericFactProperties(logarithmicScale: true, round: nil))),
          id: "Population",
          keyPath: \Country.population
        ), action: { _ in print("HI") })
          
          
      }.previewLayout(PreviewLayout.fixed(width: 250, height: 150))
      .padding()
      .previewDisplayName("Default preview")
    }
}
