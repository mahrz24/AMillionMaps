//
//  ColorThemeModifier.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 23.08.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import Resolver
import SwiftUI

struct UseColorTheme: ViewModifier {
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  func body(content: Content) -> some View {
    content.foregroundColor(Color(colorTheme.uiForeground)).accentColor(Color(colorTheme.uiAccent))
  }
}

extension View {
  func useColorTheme() -> some View {
    modifier(UseColorTheme())
  }
}
