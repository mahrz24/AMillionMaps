//
//  FilterView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI
import Resolver

class FilterViewModel: ObservableObject {
  @Injected var filteredCountryProvider: StatefulFilteredCountryProvider
  
  @Published var filters : [Fact: Condition] = [:]
    {
    didSet {
      filteredCountryProvider.apply(
        Filter(conjunctions: [Conjunction(conditions: Array(filters.values))])
      )
    }
  }
}

struct FilterView: View {
  @Injected var countryProvider: CountryProvider
 
  @State var activeFacts: [Fact] = []
  @State var filterDropdownExpanded = false
  
  @ObservedObject var viewModel: FilterViewModel = FilterViewModel()
  
  var inactiveFacts: [Fact] { Array(Set(Country.filterFacts).subtracting(Set(activeFacts))) }
  
    var body: some View {
      VStack {
        HStack{
          Spacer()
          Text("Filters")
          Spacer()
          Button(action: { self.filterDropdownExpanded.toggle() }) {
            Image(systemName: "plus")
          }.overlay(
            VStack {
              if self.filterDropdownExpanded {
                ScrollView {
                  ForEach(inactiveFacts) {
                    fact in
                     Button(action: {
                      self.activeFacts.append(fact)
                      self.viewModel.filters[fact] = Condition(fact: fact, value: ConditionValue.none)
                      self.filterDropdownExpanded.toggle()
                     }) {
                      Text(fact.id).frame(width: 150.0)
                    }
                  }
                }
                .onTapGesture {
                    print("Tapped inside!")
                }
                .frame(minHeight: 150, maxHeight: 500)
                .padding()
                .background(/*@START_MENU_TOKEN@*/Color.green/*@END_MENU_TOKEN@*/)
                .cornerRadius(/*@START_MENU_TOKEN@*/8.0/*@END_MENU_TOKEN@*/)
              } else {
                  EmptyView()
              }
            }
            .padding([.top, .trailing], 20.0)
            
            ,
            alignment: .topTrailing
          )
        }.zIndex(10)
//        GeometryReader { geometry in
          ScrollView {
        VStack{
            ForEach(self.activeFacts) {
              fact in
              FactFilterView(fact: fact, action: { self.viewModel.filters[fact] = Condition(fact: fact, value: $0) })
            }
        }
//          }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
  }
}

//
//struct FilterView_Previews: PreviewProvider {
//    static var previews: some View {
//      FilterView()
//    }
//}
