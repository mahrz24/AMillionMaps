//
//  ColorTheme.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 16.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

extension Double {
  func clip(_ lower: Double, _ upper: Double) -> Double {
    return min(max(self, lower), upper)
  }
}

struct ColorComponents {
    var r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat
}

extension UIColor {

    func getComponents() -> ColorComponents {
        if (cgColor.numberOfComponents == 2) {
          let cc = cgColor.components!
          return ColorComponents(r:cc[0], g:cc[0], b:cc[0], a:cc[1])
        }
        else {
          let cc = cgColor.components!
          return ColorComponents(r:cc[0], g:cc[1], b:cc[2], a:cc[3])
        }
    }

    func interpolateRGBColorTo(end: UIColor, fraction: CGFloat) -> UIColor {
        var f = max(0, fraction)
        f = min(1, fraction)

        let c1 = self.getComponents()
        let c2 = end.getComponents()

        let r = c1.r + (c2.r - c1.r) * f
        let g = c1.g + (c2.g - c1.g) * f
        let b = c1.b + (c2.b - c1.b) * f
        let a = c1.a + (c2.a - c1.a) * f

        return UIColor.init(red: r, green: g, blue: b, alpha: a)
    }

}

struct ColorTheme: Identifiable {
  var id: String { label }
  var label: String
  var background: UIColor
  var filtered: UIColor
  var lowValue: UIColor
  var highValue: UIColor
  
  static func makeNamedTheme(name: String, label: String) -> ColorTheme {
    return ColorTheme(label: label, background: UIColor(named: "\(name).background")!, filtered: UIColor(named: "\(name).filtered")!, lowValue: UIColor(named: "\(name).lowValue")!, highValue: UIColor(named: "\(name).highValue")!)
  }
  
  static func makeDefaultTheme() -> ColorTheme {
    return makeNamedTheme(name: "default", label: "Default")
  }
  
  static func allThemes() -> [ColorTheme] {
    [
      makeDefaultTheme(),
      makeNamedTheme(name: "classic", label: "Classic")
    ]
  }
  
  func colorForImageValue(image: Double) -> UIColor {
    return lowValue.interpolateRGBColorTo(end: highValue, fraction: CGFloat(image.clip(0, 1)))
  }
}
