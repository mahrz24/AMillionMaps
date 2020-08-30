//
//  NumericFactView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 03.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Combine
import DynamicColor
import Resolver
import Sliders
import SwiftUI

struct TickView: View {
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  var ticks: [Double]
  var color: DynamicColor

  init(ticks: [Double], color: DynamicColor) {
    self.ticks = ticks
    self.color = color
  }

//  func generateTickCapsule(_ geometry: GeometryProxy, index: Int, value: Double) -> some View {
//    let baseCapsule = Capsule().rotation(Angle(degrees: 90)).softInnerShadow()
//    let x = CGFloat(index) / CGFloat(ticks.count) * (geometry.size.width - 5)
//    let y = geometry.size.height / 2 - 2
//
//    return baseCapsule.frame(width: CGFloat(value) * 9 + 2, height: 4).offset(x: x + 5, y: y)
//  }

  var body: some View {
    ZStack {
      Rectangle().foregroundColor(.clear)
        .background(LinearGradient(gradient: Gradient(colors: [color.color,
                                                               color.shaded(amount: 0.025).color]),
                                   startPoint: .leading, endPoint: .trailing))
//      GeometryReader { geometry in
//        ForEach(self.ticks.indices, id: \.hashValue) {
//          index in self.generateTickCapsule(geometry, index: index, value: self.ticks[index])
//        }
//      }
    }
  }
}

struct NumericFactFilterView: View {
  var fact: ConstantNumericFact
  var action: (ConditionValue) -> Void
  @Injected var countryProvider: CountryProvider
  @State private var filterRange: ClosedRange<Double> = 0 ... 1
  @State private var filterBounds: ClosedRange<Double> = 0 ... 1
  @State private var factBounds: ClosedRange<Double> = 0 ... 1
  @State private var rank: [Double] = []

  @Environment(\.colorTheme) var colorTheme: ColorTheme

  var filterTicks: [Double] {
    let factBounds = toFactRange(filterBounds)

    let range = factBounds.upperBound - factBounds.lowerBound
    let exponent = floor(log(range) / log(10)) - 1

    let step = pow(10, exponent)
    let lowerTick = ceil(factBounds.lowerBound / step) * step
    let ticks = stride(from: lowerTick, to: factBounds.upperBound, by: step)

    if fact.distributeByRank {
      return ticks.map(toSliderValue).map(toViewCoordinate)
    }

    return ticks.map(toViewCoordinate)
  }

  func toViewCoordinate(_ rangeCoordinate: Double) -> Double {
    (rangeCoordinate - filterBounds.lowerBound) / (filterBounds.upperBound - filterBounds.lowerBound)
  }

  func toSliderRange(_ factRange: ClosedRange<Double>) -> ClosedRange<Double> {
    toSliderValue(factRange.lowerBound) ... toSliderValue(factRange.upperBound)
  }

  func toFactRange(_ sliderRange: ClosedRange<Double>) -> ClosedRange<Double> {
    toFactValue(sliderRange.lowerBound) ... toFactValue(sliderRange.upperBound)
  }

  func toFactValue(_ sliderValue: Double) -> Double {
    if fact.distributeByRank {
      if rank.count > 1 {
        let rankValue = sliderValue * Double(rank.count - 1)
        let index = Int(floor(rankValue))
        let linearPart = (rankValue - Double(index))

        if linearPart == 0 {
          return rank[index]
        }
        return (1 - linearPart) * rank[index] + linearPart * rank[index + 1]
      } else {
        return sliderValue
      }
    } else {
      return sliderValue
    }
  }

  func toSliderValue(_ factValue: Double) -> Double {
    if fact.distributeByRank {
      if rank.count > 1 {
        let index = rank.firstIndex { $0 > factValue } ?? rank.count - 1
        return Double(index) / Double(rank.count - 1)
      } else {
        return factValue
      }
    } else {
      return factValue
    }
  }

  var body: some View {
    ZStack(alignment: .center) {
      Rectangle().neuCard()
      HStack {
        VStack {
          HStack {
            Text(fact.id).font(.subheadline)
            Spacer()
          }
          VStack {
            RangeSlider(range: $filterRange, in: filterBounds, onEditingChanged: { _ in
              self.action(ConditionValue.numeric(self.toFactRange(self.filterRange),
                                                 self.filterRange
                                                   .lowerBound == self
                                                   .filterBounds
                                                   .lowerBound,
                                                 self.filterRange
                                                   .upperBound == self
                                                   .filterBounds
                                                   .upperBound))
            })
              .frame(height: 15)
              .rangeSliderStyle(
                HorizontalRangeSliderStyle(track:
                  HorizontalRangeTrack(view: TickView(ticks: self.filterTicks, color: colorTheme.uiAccent),
                                       mask: Rectangle())
                    .frame(height: 18)
                    .background(TickView(ticks: self.filterTicks, color: colorTheme.uiBackground).mask(Capsule())
                      .softInnerShadow(Capsule(), spread: 0.05, radius: 2)),
                                           
                  lowerThumb: Circle().softInnerShadow(Circle()).foregroundColor(colorTheme.uiBackground.color)
                    .softOuterShadow(offset: 2, radius: 1),
                                           upperThumb: Circle().softInnerShadow(Circle()).foregroundColor(colorTheme.uiBackground.color)
                    .softOuterShadow(offset: 2, radius: 1),
                                           lowerThumbSize: CGSize(width: 18, height: 18),
                                           upperThumbSize: CGSize(width: 18, height: 18))
              )
            HStack {
              Text(formatNumber(toFactValue(filterRange.lowerBound), truncate: self.fact.round ?? 1)).font(.footnote)
              Spacer()
              Text(formatNumber(toFactValue(filterRange.upperBound), truncate: self.fact.round ?? 1)).font(.footnote)
            }
          }
        }.padding()
      }
    }
    .onAppear {
      let numericFactMetadata: NumericMetadata = self.countryProvider.factMetadata(AnyFact(with: self.fact)).unwrap()!
      self.rank = self.countryProvider.factRank(self.fact).map { $0.1 }
      self.factBounds = numericFactMetadata.range

      if !self.fact.distributeByRank {
        self.filterRange = numericFactMetadata.range
        self.filterBounds = numericFactMetadata.range
      }
    }
  }
}

struct NumericFactFilterView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      NumericFactFilterView(fact: ConstantNumericFact(distributeByRank: false, round: 0, unit: nil,
                                                      id: "Population",
                                                      keyPath: \Country.population,
                                                      columnAttribues: ColumnAttributes(width: 200)), action: { _ in print("HI") })

      NumericFactFilterView(fact: ConstantNumericFact(distributeByRank: true, round: nil, unit: nil,
                                                      id: "Population",
                                                      keyPath: \Country.population,
                                                      columnAttribues: ColumnAttributes(width: 200)), action: { _ in print("HI") })

    }.useColorTheme().previewLayout(PreviewLayout.fixed(width: 250, height: 250))
      .padding()
      .previewDisplayName("Default preview")
  }
}
