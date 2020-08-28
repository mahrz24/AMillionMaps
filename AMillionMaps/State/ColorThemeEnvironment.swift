//
//  ColorThemeEnvironment.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 27.08.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import SwiftUI

struct ColorThemeKey: EnvironmentKey {
  static let defaultValue: ColorTheme = ColorTheme.makeDefaultTheme()
}

extension EnvironmentValues {
  var colorTheme: ColorTheme {
    get {
      self[ColorThemeKey.self]
    }
    set {
      self[ColorThemeKey.self] = newValue
    }
  }
}
