//
//  ColorTheme.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 16.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import DynamicColor
import Foundation
import SwiftUI
import UIKit

extension Double {
  func clip(_ lower: Double, _ upper: Double) -> Double {
    min(max(self, lower), upper)
  }
}

extension DynamicColor {
  var color: Color {
    Color(self)
  }
}

struct ColorTheme: Identifiable {
  var id: String { label }
  var label: String

  var uiBackground: DynamicColor
  var uiForeground: DynamicColor
  var uiAccent: DynamicColor

  var uiLightShadow: DynamicColor
  var uiDarkShadow: DynamicColor

  var mapBackground: DynamicColor
  var mapFiltered: DynamicColor
  var mapLowValue: DynamicColor
  var mapHighValue: DynamicColor
  var mapLabelText: DynamicColor
  var mapBorder: DynamicColor

  static func makeDefaultTheme() -> ColorTheme {
    ColorTheme(label: "Default",
               uiBackground: DynamicColor(hexString: "#ecf0f3"),
               uiForeground: DynamicColor(hexString: "#999999"),
               uiAccent: DynamicColor(hexString: "#9999ff"),
               uiLightShadow: DynamicColor(hexString: "#FFFFFF"),
               uiDarkShadow: DynamicColor(hexString: "#d1d9e6"),
               mapBackground: DynamicColor(hexString: "#ecf0f3").shaded(amount: 0.1),
               mapFiltered: DynamicColor(hexString: "#ecf0f3").shaded(amount: 0.2),
               mapLowValue: DynamicColor(hexString: "#9999ff").shaded(amount: 0.5),
               mapHighValue: DynamicColor(hexString: "#9999ff").tinted(amount: 0.5),
               mapLabelText: DynamicColor(hexString: "#F54A45"),
               mapBorder: DynamicColor(hexString: "#F54A45"))
  }

  static func allThemes() -> [ColorTheme] {
    [
      makeDefaultTheme(),
    ]
  }

  func colorForImageValue(image: ImageValue?) -> Color {
    let uiColor: UIColor = colorForImageValue(image: image)
    return Color(uiColor)
  }

  func colorForImageValue(image: ImageValue?) -> UIColor {
    guard let image = image else {
      return mapFiltered
    }
    switch image {
    case let .Numeric(image):
      return mapLowValue.mixed(withColor: mapHighValue, weight: CGFloat(image.clip(0, 1)))
    case let .Categorical(image):
      return [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.purple, UIColor.magenta][image % 4]
    }
  }
}
