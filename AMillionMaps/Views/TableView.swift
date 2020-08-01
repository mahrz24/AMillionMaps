//
//  TableView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 25.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI

struct TableView: View {
  @Injected var filterState: FilterState

  private var numberOfItems: Int {
    Country.tableFacts.count
  }

  var body: some View {
    TableWithHeadersView()
  }

//      GeometryReader{ geometry in
//        ScrollView {
//          VStack{
//            HStack {
//              VStack {
//                ForEach(self.filterState.countries) {
//                  country in
//                  HStack {
//                    Text(country.id).padding(8)
//                    .frame(width: 150, height: 50)
//                    .background(Color.orange)
//                    .border(Color.red)
//                    Spacer()
//                  }
//                }
//              }
//
//              ForEach(Country.tableFacts, id: \.id) {
//                fact in
//                VStack {
//                  ForEach(self.filterState.countries) {
//                    country in
//                    HStack {
//                    self.format(country: country, fact: fact).padding(8)
//                    .frame(width: 350, height: 50)
//                    .background(Color.orange)
//                    .border(Color.red)
//                      Spacer()
//                    }
//                  }
//                }
//              }
//            }
//
//          }
//        }.frame(width: geometry.size.width, height: geometry.size.height)
//      }
//    }

  func format(country: Country, fact: AnyFact) -> some View {
    if let value = country[keyPath: fact.keyPath] {
      switch value {
      case let .Categorical(category):
        return Text(category)
      case let .Numeric(value):
        return Text("\(value)")
      }
    } else {
      return Text("N/A")
    }
  }
}

//
// struct TableView_Previews: PreviewProvider {
//    static var previews: some View {
//        TableView()
//    }
// }
