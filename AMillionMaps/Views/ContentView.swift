//
//  ContentView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 30.06.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI

enum SelectorViewState {
  case hidden
  case filterFactSelection
  case colorFactSelection
  case labelFactSelection
  case colorThemeSelection
  case domainMapperSelection
}

struct ContentView: View {
  // Global states needed for the fact selectors / other pickers
  @State var selectorState: SelectorViewState = .hidden

  @ObservedObject var filterViewModel = FilterViewModel()
  @ObservedObject var colorViewModel: ColorAndDataState = Resolver.resolve()

  func generateSelectorView() -> AnyView {
    switch selectorState {
    case .filterFactSelection:
      return AnyView(
        FactSelectionView(filterViewModel).padding()
      )
    case .colorFactSelection:
      return AnyView(
        OptionalListPicker(.constant(Country.mapFacts), selected: $colorViewModel.fact) {
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
    case .labelFactSelection:
      return AnyView(
        OptionalListPicker(.constant(Country.mapFacts), selected: $colorViewModel.labelFact) {
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
        ListPicker(.constant(ColorTheme.allThemes()), selected: $colorViewModel.colorTheme) {
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
          AnyDomainMapperFactory(with: RankDomainMapperFactory()),
          AnyDomainMapperFactory(with: CategoricalDomainMapperFactory()),
        ]), selected: $colorViewModel.domainMapperFactory) {
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

  @State private var xScrollOffset: CGFloat = 0
  @State private var yScrollOffset: CGFloat = 0

  @State private var xOffset: CGFloat = 0
  @State private var yOffset: CGFloat = 0

  private var xTotalOffset: CGFloat { xOffset + xScrollOffset }
  private var yTotalOffset: CGFloat { yOffset + yScrollOffset }

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
          VStack(spacing: 0) {
            ZStack {
              MapView()
              VStack{
                HStack {
                  Spacer()
                  LegendView().padding(25)
                }
                Spacer()
              }
            }
            TableView().frame(height: 350).padding(.bottom, 20)
          }
          HStack {
            if self.selectorState == .hidden {
              EmptyView()
            } else {
              SettingsOverlayView {
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
