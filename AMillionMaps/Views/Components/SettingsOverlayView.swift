//
//  SettingsOverlayView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 17.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct SettingsOverlayView<Content: View>: View {
  
  let viewBuilder: () -> Content
  
  init(_ viewBuilder: @escaping () -> Content) {
      self.viewBuilder = viewBuilder
  }
  
    var body: some View {
      ZStack {
        BlurView(style: .light)
        Rectangle().foregroundColor(Color.gray).opacity(0.25)
        self.viewBuilder()
      }
    }
}

struct SettingsOverlayView_Previews: PreviewProvider {
    static var previews: some View {
      SettingsOverlayView() {
        Text("Hi")
      }
    }
}
