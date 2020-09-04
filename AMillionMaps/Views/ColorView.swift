//
//  ColorView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 10.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI

struct PartialRoundedButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat
    var corners: UIRectCorner
  
    @Environment(\.colorTheme) var colorTheme: ColorTheme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(cornerRadius)
            .background(
              RoundedCorner(radius: cornerRadius, corners: corners).foregroundColor(colorTheme.uiBackground.darkened(amount: 0.01).color)
            )
          .foregroundColor(colorTheme.uiForeground.color)
    }
}


struct ColorView: View {
  @ObservedObject var selectionViewModel: SelectionViewState = Resolver.resolve()
  @ObservedObject var viewModel: ColorAndDataState = Resolver.resolve()
  
  @Environment(\.colorTheme) var colorTheme: ColorTheme

  func selectedFactView() -> some View {
    if let selectedFact = viewModel.fact {
      return Text(selectedFact.id).lineLimit(1)
    } else {
      return Text("Color").foregroundColor(.accentColor).lineLimit(1)
    }
  }
  
  func mapperSelection() -> some View {
    if let selectedFact = viewModel.fact {
      return AnyView(
        VStack(spacing: 0){
          Rectangle().frame(width: 241, height: 1).foregroundColor(.accentColor)
        SidePanelButton(panelBuilder: {
          ListPicker(.constant([
            AnyDomainMapperFactory(with: LinearDomainMapperFactory()),
            AnyDomainMapperFactory(with: RankDomainMapperFactory()),
            AnyDomainMapperFactory(with: CategoricalDomainMapperFactory()),
          ]), selected: self.$viewModel.domainMapperFactory) {
            fact, selected in RadioBox(selected: selected, label: fact.id)
          }
        }
        ) {
          Text(self.viewModel.domainMapperFactory.id).lineLimit(1).frame(width: 241, height: 30).font(Font.system(.footnote).smallCaps())
      }.buttonStyle(PartialRoundedButtonStyle(cornerRadius: 0, corners: []))
          Rectangle().frame(width: 241, height: 1).foregroundColor(.accentColor)
      })
    } else {
      return AnyView(
        Rectangle().frame(width: 241, height: 1).foregroundColor(.accentColor)
      )
    }
  }

  func selectedLabelFactView() -> some View {
    if let selectedFact = viewModel.labelFact {
      return Text(selectedFact.id).lineLimit(1)
    } else {
      return Text("Label").foregroundColor(.accentColor).lineLimit(1)
    }
  }

  var body: some View {
    VStack{
      VStack(spacing:0) {
        HStack(spacing:0) {
          
          SidePanelButton(panelBuilder: {
            OptionalListPicker(.constant(Country.mapFacts), selected: self.$viewModel.fact) {
              fact, selected in RadioBox(selected: selected, label: fact?.id ?? "None")
            }
          }
          ) {
            self.selectedFactView().frame(width: 100, height: 22).font(Font.system(.footnote).smallCaps())
          }.buttonStyle(PartialRoundedButtonStyle(cornerRadius: 10, corners: [.topLeft]))
          Rectangle().frame(width: 1, height: 40).foregroundColor(.accentColor)
          SidePanelButton(panelBuilder: {
            OptionalListPicker(.constant(Country.mapFacts), selected: self.$viewModel.labelFact) {
              fact, selected in RadioBox(selected: selected, label: fact?.id ?? "None")
            }
          }
          ) {
            HStack(spacing:0){
              self.selectedLabelFactView().frame(width: 73, height: 22).font(Font.system(.footnote).smallCaps()).padding(.trailing, 5)
            Image(systemName: "lock.open").frame(width:22, height: 22).neumorphic()
            }
          }.buttonStyle(PartialRoundedButtonStyle(cornerRadius: 10, corners: [.topRight]))
        }
        
      
      
        
      self.mapperSelection()
        
      SidePanelButton(panelBuilder: {
        VStack{
          HStack {
            Toggle(isOn: self.$viewModel.showFiltered) {
              Text("Show Filtered")
            }.toggleStyle(NeumorphicToggleStyle())
          }
          ListPicker(.constant(ColorTheme.allThemes()), selected: self.$viewModel.colorTheme) {
            fact, selected in RadioBox(selected: selected, label: fact.id)
          }
        }
      }
      ) {
        Text(self.viewModel.colorTheme.label).frame(width: 221, height: 20).font(Font.system(.footnote).smallCaps())
      }.buttonStyle(PartialRoundedButtonStyle(cornerRadius: 10, corners: [.bottomLeft, .bottomRight]))
      }.padding(.bottom, 25).softOuterShadow()
      
      

    }.padding([.leading, .trailing], 15)
  }
}

struct ColorView_Previews: PreviewProvider {
  static var previews: some View {
    ColorView(viewModel: ColorAndDataState())
  }
}
