//
//  TableView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 25.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI
import Combine

struct TableView: View {
  @ObservedObject var filterState: FilterState = Resolver.resolve()

  @State var cols = Country.tableFacts
  @State var countries: [Country] = []

  @State private var filterUpdate: AnyCancellable? = nil
  
  private var numberOfItems: Int {
    Country.tableFacts.count
  }
  
  func update() {
    countries = filterState.countries
    countries.sort {
      $0.id < $1.id
    }
  }

  var body: some View {
    TableWithHeadersView(self.$countries, self.$cols,
                         colWidth: { fact in CGFloat(fact.columnAttribues.width ?? 150) },
                         headerColWidth: 85,
                         rowHeight: 30.0,
                         {
                           row in Text("\(row.id)")
                         }, {
                           col in Text("\(col.id)")
    }) {
      (country, fact) -> AnyView in
      if let value = country[keyPath: fact.keyPath] {
        if let formattedValue = fact.format(value) {
          var resultStr = formattedValue.value
          if let unit = formattedValue.unit {
            resultStr += " \(unit)"
          }
          switch formattedValue.alignment {
          case .left:
            return AnyView(HStack{
              Text(resultStr)
              Spacer()
            })
          case .center:
          return AnyView(HStack{
            Text(resultStr)
          })
          case .right:
          return AnyView(HStack{
            Spacer()
            Text(resultStr)
            
          })
          }
          
        }
      }
      return AnyView(HStack { Text("N/A") })
    }.onAppear() {
      // TODO: Move this to a table state
      self.filterUpdate = self.filterState.countriesDidChange.debounce(for: .milliseconds(50), scheduler: RunLoop.main).sink {
        self.update()
      }
    }
  }
}

//
// struct TableView_Previews: PreviewProvider {
//    static var previews: some View {
//        TableView()
//    }
// }
