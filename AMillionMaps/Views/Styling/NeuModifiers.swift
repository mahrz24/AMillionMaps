//
//  ColorThemeModifier.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 23.08.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import Neumorphic
import Resolver
import SwiftUI



struct PaddedIconModifier: ViewModifier {
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  func body(content: Content) -> some View {
    HStack{
      content.padding(4)
    }
  }
}


extension View {
  func paddedIcon() -> some View {
    modifier(PaddedIconModifier())
  }
}



struct NeumorphicElementModifier: ViewModifier {
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  func body(content: Content) -> some View {
    content
      .background(LinearGradient(gradient: Gradient(colors: [colorTheme.uiBackground.color,
                                                             colorTheme.uiBackground.darkened(amount: 0.05).color]),
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing))
      .cornerRadius(5)
    .softOuterShadow(offset:1, radius: 2)
    
      
  }
}

struct NeumorphicElementPressedModifier: ViewModifier {
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  func body(content: Content) -> some View {
    content
      .background(LinearGradient(gradient: Gradient(colors: [colorTheme.uiBackground.color,
                                                             colorTheme.uiBackground.darkened(amount: 0.05).color]),
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing))
      .cornerRadius(5)
    .softInnerShadow(RoundedRectangle(cornerRadius: 5), spread: 0.25, radius: 2)
    
      
  }
}

extension View {
  func neumorphic() -> some View {
    modifier(NeumorphicElementModifier())
  }
}

extension View {
  func neumorphicPressed() -> some View {
    modifier(NeumorphicElementPressedModifier())
  }
}


struct NeuCardModifier: ViewModifier {
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  func body(content: Content) -> some View {
    content
      .foregroundColor(.clear)
      .background(LinearGradient(gradient: Gradient(colors: [colorTheme.uiBackground.color,
                                                             colorTheme.uiBackground.darkened(amount: 0.05).color]),
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing))
      .cornerRadius(20)
      .softOuterShadow()
  }
}

extension View {
  func neuCard() -> some View {
    modifier(NeuCardModifier())
  }
}

extension View {
  func inverseMask<Mask>(_ mask: Mask) -> some View where Mask: View {
    self.mask(mask
      .foregroundColor(.black)
      .background(Color.white)
      .compositingGroup()
      .luminanceToAlpha()
    )
  }
}

private struct SoftOuterShadowViewModifier: ViewModifier {
  var offset: CGFloat
  var radius: CGFloat

  @Environment(\.colorTheme) var colorTheme: ColorTheme

  func body(content: Content) -> some View {
    content
      .shadow(color: colorTheme.uiDarkShadow.color, radius: radius, x: offset, y: offset)
      .shadow(color: colorTheme.uiLightShadow.color, radius: radius, x: -offset, y: -offset)
  }
}

extension View {
  public func softOuterShadow(offset: CGFloat = 7, radius: CGFloat = 10) -> some View {
    modifier(SoftOuterShadowViewModifier(offset: offset, radius: radius))
  }
}

private struct SoftInnerShadowViewModifier<S: Shape>: ViewModifier {
  var shape: S
  var spread: CGFloat = 0.5 // The value of spread is between 0 to 1. Higher value makes the shadow look more intense.
  var radius: CGFloat = 10

  @Environment(\.colorTheme) var colorTheme: ColorTheme

  init(shape: S, spread: CGFloat, radius: CGFloat) {
    self.shape = shape
    self.spread = spread
    self.radius = radius
  }

  fileprivate func strokeLineWidth(_ geo: GeometryProxy) -> CGFloat {
    geo.size.width * 0.10
  }

  fileprivate func strokeLineScale(_ geo: GeometryProxy) -> CGFloat {
    let lineWidth = strokeLineWidth(geo)
    return geo.size.width / CGFloat(geo.size.width - lineWidth)
  }

  fileprivate func shadowOffset(_ geo: GeometryProxy) -> CGFloat {
    geo.size.width * 0.5 * min(max(spread, 0), 1)
  }

  fileprivate func addSoftInnerShadow(_: SoftInnerShadowViewModifier.Content) -> some View {
    GeometryReader { geo in

      self.shape.fill(self.colorTheme.uiLightShadow.color)
        .inverseMask(
          self.shape
            .offset(x: -self.shadowOffset(geo), y: -self.shadowOffset(geo))
        )
        .offset(x: self.shadowOffset(geo), y: self.shadowOffset(geo))
        .blur(radius: self.radius)
        .shadow(color: self.colorTheme.uiLightShadow.color, radius: self.radius, x: -self.shadowOffset(geo) / 2,
                y: -self.shadowOffset(geo) / 2)
        .mask(
          self.shape
        )
        .overlay(
          self.shape
            .fill(self.colorTheme.uiDarkShadow.color)
            .inverseMask(
              self.shape
                .offset(x: self.shadowOffset(geo), y: self.shadowOffset(geo))
            )
            .offset(x: -self.shadowOffset(geo), y: -self.shadowOffset(geo))
            .blur(radius: self.radius)
            .shadow(color: self.colorTheme.uiDarkShadow.color, radius: self.radius, x: self.shadowOffset(geo) / 2,
                    y: self.shadowOffset(geo) / 2)
        )
        .mask(
          self.shape
        )
    }
  }

  func body(content: Content) -> some View {
    content.overlay(
      addSoftInnerShadow(content)
    )
  }
}

// For more readable, we extend the View and create a softInnerShadow function.
extension View {
  public func softInnerShadow<S: Shape>(_ content: S, spread: CGFloat = 0.5, radius: CGFloat = 10) -> some View {
    modifier(
      SoftInnerShadowViewModifier(shape: content, spread: spread, radius: radius)
    )
  }
}

private struct SoftInnerHorizontalShadowViewModifier<S: Shape>: ViewModifier {
  var shape: S
  var spread: CGFloat = 0.5 // The value of spread is between 0 to 1. Higher value makes the shadow look more intense.
  var radius: CGFloat = 10

  @Environment(\.colorTheme) var colorTheme: ColorTheme

  init(shape: S, spread: CGFloat, radius: CGFloat) {
    self.shape = shape
    self.spread = spread
    self.radius = radius
  }

  fileprivate func strokeLineWidth(_ geo: GeometryProxy) -> CGFloat {
    geo.size.width * 0.10
  }

  fileprivate func strokeLineScale(_ geo: GeometryProxy) -> CGFloat {
    let lineWidth = strokeLineWidth(geo)
    return geo.size.width / CGFloat(geo.size.width - lineWidth)
  }

  fileprivate func shadowOffset(_ geo: GeometryProxy) -> CGFloat {
    geo.size.width * 0.5 * min(max(spread, 0), 1)
  }

  fileprivate func addSoftInnerShadow(_: SoftInnerHorizontalShadowViewModifier.Content) -> some View {
    GeometryReader { geo in

      self.shape.fill(self.colorTheme.uiLightShadow.color)
        .inverseMask(
          self.shape
            .offset(x: -self.shadowOffset(geo), y: 0)
        )
        .offset(x: self.shadowOffset(geo), y: 0)
        .blur(radius: self.radius)
        .shadow(color: self.colorTheme.uiLightShadow.color, radius: self.radius, x: -self.shadowOffset(geo) / 2, y: 0)
        .mask(
          self.shape
        )
        .overlay(
          self.shape
            .fill(self.colorTheme.uiDarkShadow.color)
            .inverseMask(
              self.shape
                .offset(x: self.shadowOffset(geo), y: 0)
            )
            .offset(x: -self.shadowOffset(geo), y: 0)
            .blur(radius: self.radius)
            .shadow(color: self.colorTheme.uiDarkShadow.color, radius: self.radius, x: self.shadowOffset(geo) / 2, y: 0)
        )
        .mask(
          self.shape
        )
    }
  }

  func body(content: Content) -> some View {
    content.overlay(
      addSoftInnerShadow(content)
    )
  }
}

// For more readable, we extend the View and create a softInnerShadow function.
extension View {
  public func softHorizontalInnerShadow<S: Shape>(_ content: S, spread: CGFloat = 0.5, radius: CGFloat = 10) -> some View {
    modifier(
      SoftInnerHorizontalShadowViewModifier(shape: content, spread: spread, radius: radius)
    )
  }
}
