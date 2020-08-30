//
//  ContentView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 30.06.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI

struct ThemedContentView: View {
  @ObservedObject var colorViewModel: ColorAndDataState = Resolver.resolve()

  var body: some View {
    ContentView().environment(\.colorTheme, colorViewModel.colorTheme)
  }
}

struct ContentView: View {
  // Global states needed for the fact selectors / other pickers

  @ObservedObject var selectionViewModel: SelectionViewState = Resolver.resolve()

  @Environment(\.colorTheme) var colorTheme: ColorTheme

  func generateLeftSidePanelSelector(_ geometry: GeometryProxy) -> AnyView {
    // TODO: make two properties and a simple if / else out it
    switch selectionViewModel.leftSidePanelState {
    case let .visible(viewBuilder):
      return AnyView(SettingsOverlayView {
        VStack {
          HStack {
            Button(action: { self.selectionViewModel.leftSidePanelState = .hidden }) {
              Image(systemName: "chevron.left.square.fill")
              Text("Close")
            }
            Spacer()
          }.padding(.top, geometry.safeAreaInsets.top)
          viewBuilder().padding(.top, 10)
        }.padding()
      }.frame(width: 250))
    case .hidden:
      return AnyView(EmptyView())
    }
  }

  var body: some View {
    ZStack {
      Rectangle().foregroundColor(Color(colorTheme.uiBackground)).edgesIgnoringSafeArea(.all)
      GeometryReader { geometry in
        HStack {
          ZStack {
            VStack {
              FilterView().padding(.top, geometry.safeAreaInsets.top)
              ColorView().frame(minHeight: 300)
            }
          }.frame(maxWidth: 300)
          ZStack {
            VStack(spacing: 0) {
              ZStack {
                MapView()
                VStack {
                  HStack {
                    Spacer()
                    LegendView().padding(35)
                  }
                  Spacer()
                }
              }
              TableView().frame(height: 350).padding(.bottom, 20)
            }
            HStack {
              self.generateLeftSidePanelSelector(geometry).transition(.move(edge: .top))
              Spacer()
            }
          }
        }.edgesIgnoringSafeArea(.all).useColorTheme()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
