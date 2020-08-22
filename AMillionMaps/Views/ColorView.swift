//
//  ColorView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 10.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI

struct ColorView: View {
  @ObservedObject var selectionViewModel: SelectionViewState = Resolver.resolve()
  @ObservedObject var viewModel: ColorAndDataState

  func selectedFactView() -> Text {
    if let selectedFact = viewModel.fact {
      return Text(selectedFact.id)
    } else {
      return Text("Tap here to select fact.")
    }
  }

  func selectedLabelFactView() -> AnyView {
    if let selectedFact = viewModel.labelFact {
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

        SidePanelButton(panelBuilder: {
          OptionalListPicker(.constant(Country.mapFacts), selected: self.$viewModel.fact) {
            fact, selected in Checkbox(selected: selected, label: fact.id)
          }
        }
        ) {
          self.selectedFactView()
        }
      }
      HStack {
        Text("Label Fact:")
        Spacer()
        SidePanelButton(panelBuilder: {
          OptionalListPicker(.constant(Country.mapFacts), selected: self.$viewModel.labelFact) {
            fact, selected in Checkbox(selected: selected, label: fact.id)
          }
        }
        ) {
          self.selectedLabelFactView()
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
        SidePanelButton(panelBuilder: {
          ListPicker(.constant(ColorTheme.allThemes()), selected: self.$viewModel.colorTheme) {
            fact, selected in Checkbox(selected: selected, label: fact.id)
          }
        }
        ) {
          Text(self.viewModel.colorTheme.label)
        }
      }
      HStack {
        Text("Mapping:")
        Spacer()

        SidePanelButton(panelBuilder: {
          ListPicker(.constant([
            AnyDomainMapperFactory(with: LinearDomainMapperFactory()),
            AnyDomainMapperFactory(with: RankDomainMapperFactory()),
            AnyDomainMapperFactory(with: CategoricalDomainMapperFactory()),
          ]), selected: self.$viewModel.domainMapperFactory) {
            fact, selected in Checkbox(selected: selected, label: fact.id)
          }
        }
        ) {
          Text(self.viewModel.domainMapperFactory.id)
        }
      }
    }
  }
}

struct ColorView_Previews: PreviewProvider {
  static var previews: some View {
    ColorView(viewModel: ColorAndDataState())
  }
}
