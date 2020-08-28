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
  var uiBackgroundSecondary: DynamicColor

  var uiForeground: DynamicColor
  var uiForegroundSecondary: DynamicColor

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
               uiBackground: DynamicColor(hexString: "#fbfbfb"),
               uiBackgroundSecondary: DynamicColor(hexString: "#f1f1f1"),
               uiForeground: DynamicColor(hexString: "#999999"),
               uiForegroundSecondary: DynamicColor(hexString: "#888888"),
               uiAccent: DynamicColor(hexString: "#fbfbff"),
               uiLightShadow: DynamicColor(hexString: "#FFFFFF"),
               uiDarkShadow: DynamicColor(hexString: "#cfcfcf"),
               mapBackground: DynamicColor(hexString: "#BA8D8D"),
               mapFiltered: DynamicColor(hexString: "#F54A45"),
               mapLowValue: DynamicColor(hexString: "#F54A45"),
               mapHighValue: DynamicColor(hexString: "#CBA2A2"),
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
