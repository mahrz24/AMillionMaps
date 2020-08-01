//
//  FactSelectionView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 11.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Combine
import Resolver
import SwiftUI

struct FactState: Identifiable, Hashable {
  var id: String { fact.id }
  var enabled: Bool
  var fact: AnyFact
}

struct CheckboxToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      Image(systemName: configuration.isOn ? "checkmark.square" : "square")
        .resizable()
        .frame(width: 14, height: 14)
      configuration.label
      Spacer()
    }.onTapGesture { configuration.isOn.toggle() }
  }
}

struct FactSelectionView: View {
  @Injected var countryProvider: CountryProvider

  @ObservedObject var viewModel: FilterViewModel

  init(_ viewModel: FilterViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    ScrollView {
      VStack {
        ForEach(self.viewModel.factStates.indices) {
          index in
          Toggle(isOn: self.$viewModel.factStates[index].enabled) {
            Text(self.viewModel.factStates[index].fact.id).font(.footnote)
          }.padding(.horizontal, 5).toggleStyle(CheckboxToggleStyle())
        }
      }
    }
  }
}

// d
