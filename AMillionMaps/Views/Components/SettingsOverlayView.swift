//
//  SettingsOverlayView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 17.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct SettingsOverlayView<Content: View>: View {
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  let viewBuilder: () -> Content

  init(_ viewBuilder: @escaping () -> Content) {
    self.viewBuilder = viewBuilder
  }

  var body: some View {
    ZStack {
      Rectangle().foregroundColor(colorTheme.uiBackground.tinted(amount: 0.05).color).softHorizontalInnerShadow(Rectangle(), spread: 0.1, radius: 5)
      self.viewBuilder()
    }
  }
}

struct SettingsOverlayView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsOverlayView {
      Text("Hi")
    }
  }
}
