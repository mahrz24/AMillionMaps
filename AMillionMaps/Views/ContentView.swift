//
//  ContentView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 30.06.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI
import Resolver

enum SelectorViewState {
  case hidden
  case filterFactSelection
  case colorFactSelection
  case colorThemeSelection
  case domainMapperSelection
}

struct ContentView: View {
  
  // Global states needed for the fact selectors / other pickers
  @State var selectorState: SelectorViewState = .hidden
  
  @ObservedObject var filterViewModel = FilterViewModel()
  @ObservedObject var colorViewModel: ColorAndDataState = Resolver.resolve()
  
  func generateSelectorView() -> AnyView {
    switch(selectorState) {
      case .filterFactSelection:
        return AnyView(
          FactSelectionView(self.filterViewModel).padding()
        )
      case .colorFactSelection:
      return AnyView(
        OptionalListPicker(.constant(Country.mapFacts), selected: self.$colorViewModel.fact) {
          fact, selected in
          HStack {
            Image(systemName: selected ? "checkmark.square" : "square")
            .resizable()
            .frame(width: 14, height: 14)
            Text(fact.id)
            Spacer()
          }
        }.padding()
      )
      case .colorThemeSelection:
      return AnyView(
        ListPicker(.constant(ColorTheme.allThemes()), selected: self.$colorViewModel.colorTheme) {
          fact, selected in
          HStack {
            Image(systemName: selected ? "checkmark.square" : "square")
            .resizable()
            .frame(width: 14, height: 14)
            Text(fact.id)
            Spacer()
          }
        }.padding()
      )
      case .domainMapperSelection:
      return AnyView(
        ListPicker(.constant([
          AnyDomainMapperFactory(with: LinearDomainMapperFactory()),
          AnyDomainMapperFactory(with: RankDomainMapperFactory())
        ]), selected: self.$colorViewModel.domainMapperFactory) {
          fact, selected in
          HStack {
            Image(systemName: selected ? "checkmark.square" : "square")
            .resizable()
            .frame(width: 14, height: 14)
            Text(fact.id)
            Spacer()
          }
        }.padding()
      )
      default:
        return AnyView(EmptyView())
    }
  }
  
  var body: some View {
    GeometryReader { geometry in
      HStack {
        ZStack {
          VStack {
            FilterView(selectorViewState: self.$selectorState, viewModel: self.filterViewModel).padding(.top, geometry.safeAreaInsets.top)
            ColorView(selectorViewState: self.$selectorState, viewModel: self.colorViewModel).frame(minHeight: 300)
          }
        }.frame(maxWidth: 300).padding(10)
        ZStack {
          VStack {
            MapView()
            Text("Table")
          }
          HStack {
            if self.selectorState == .hidden {
              EmptyView()
            } else {
              SettingsOverlayView() {
                VStack {
                  HStack {
                    Button(action: { self.selectorState = .hidden }) {
                      Image(systemName: "chevron.left.square.fill")
                      Text("Close")
                    }
                    Spacer()
                    }.padding().padding(.top, geometry.safeAreaInsets.top)
                  self.generateSelectorView()
                }
              }.frame(width: 250)
            }
            Spacer()
          }
        }
      }.edgesIgnoringSafeArea(.all)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
