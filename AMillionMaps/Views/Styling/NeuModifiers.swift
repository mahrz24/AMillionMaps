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

struct NeuCardModifier: ViewModifier {
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  func body(content: Content) -> some View {
    content
      .foregroundColor(.clear)
      .background(LinearGradient(gradient: Gradient(colors: [colorTheme.uiBackground.color,
                                                             colorTheme.uiBackground.darkened(amount: 0.1).color]), startPoint: .topLeading,
                                 endPoint: .bottomTrailing))
      .cornerRadius(20)
      .neuShadows(6)
  }
}

extension View {
  func neuCard() -> some View {
    modifier(NeuCardModifier())
  }
}

struct NeuShadowsModifier: ViewModifier {
  @Environment(\.colorTheme) var colorTheme: ColorTheme
  let radius: CGFloat

  func body(content: Content) -> some View {
    content
      .shadow(color: colorTheme.uiDarkShadow.color, radius: 2 * radius, x: radius, y: radius)
      .shadow(color: colorTheme.uiLightShadow.color, radius: 2 * radius, x: -radius, y: -radius)
  }
}

extension View {
  func neuShadows(_ radius: CGFloat) -> some View {
    modifier(NeuShadowsModifier(radius: radius))
  }
}

extension LinearGradient {
  init(_ colors: Color...) {
    self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
  }
}

extension Shape {
  func neuInnerShadows(_ radius: CGFloat, colorTheme: ColorTheme) -> some View {
    overlay(
      stroke(colorTheme.uiDarkShadow.color, lineWidth: radius * 2)
        .blur(radius: radius * 4)
        .offset(x: radius, y: radius)
        .mask(fill(LinearGradient(Color.black, Color.clear)))
    )
    .overlay(
      stroke(colorTheme.uiLightShadow.color, lineWidth: radius * 2)
        .blur(radius: radius * 4)
        .offset(x: -radius, y: -radius)
        .mask(fill(LinearGradient(Color.clear, Color.black)))
    )
  }
}
