//
//  ColorView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 10.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI
import Resolver


struct ColorView: View {
  
  @Binding var selectorViewState: SelectorViewState
  @ObservedObject var viewModel: ColorAndDataState
  
  func selectedFactView() -> AnyView {
    if let selectedFact = self.viewModel.fact {
      return AnyView(Text(selectedFact.id))
    } else {
      return AnyView(Text("Tap here to select fact."))
    }
  }
  
  var body: some View {
    VStack {
      HStack {
        Text("Data & Color").font(.title)
        Spacer()
      }
      HStack {
        Text("Visualize Fact:")
        Spacer()
        Button(action: { self.selectorViewState = .colorFactSelection }) {
            selectedFactView()
          }
      }
      HStack {
        Toggle(isOn: self.$viewModel.showFiltered) {
          Text("Show Filtered:")
        }
      }
      HStack {
        Text("Color Theme:")
        Spacer()
        Button(action: { self.selectorViewState = .colorThemeSelection }) {
          Text(self.viewModel.colorTheme.label)
          }
      }
    }
  }
}

struct ColorView_Previews: PreviewProvider {
  static var previews: some View {
    ColorView(selectorViewState: .constant(.hidden), viewModel: ColorAndDataState())
  }
}
