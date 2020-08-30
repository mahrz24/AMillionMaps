//
//  TableView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 25.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Combine
import Resolver
import SwiftUI

struct TableView: View {
  @ObservedObject var filterState: FilterState = Resolver.resolve()

  @State var cols = Country.tableFacts
  @State var countries: [Country] = []
  @State var orderById: AnyFact?
  @State var orderDescending: Bool = true

  @State private var filterUpdate: AnyCancellable? = nil

  private var numberOfItems: Int {
    Country.tableFacts.count
  }

  func update() {
    countries = filterState.countries
    countries.sort {
      var result: Bool = false
      if let orderById = orderById {
        let val0 = $0[keyPath: orderById.keyPath]
        let val1 = $1[keyPath: orderById.keyPath]

        if val0 == val1 {
          result = false
        } else if val0 == nil {
          result = false
        } else if val1 == nil {
          result = true
        } else {
          if let val0 = val0, let val1 = val1 {
            result = val0 < val1
          }

          if orderDescending {
            result = !result
          }
        }

      } else {
        result = $0.id < $1.id

        if orderDescending {
          result = !result
        }
      }

      return result
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
                           col in HStack {
                            Spacer()
                            Text("\(col.id)")
                            Spacer()
                             if col == self.orderById {
                               if self.orderDescending {
                                Image(systemName: "arrow.down.square.fill").resizable()
                                .frame(width: 14, height: 14).paddedIcon().neumorphicPressed().foregroundColor(Color.accentColor)
                               } else {
                                 Image(systemName: "arrow.up.square.fill").resizable()
                                 .frame(width: 14, height: 14).paddedIcon().neumorphicPressed().foregroundColor(Color.accentColor)
                               }
                             } else {
                                Image(systemName: "arrow.up.arrow.down.square").resizable()
                                .frame(width: 14, height: 14).paddedIcon().neumorphic()
                             }
                           }.contentShape(Rectangle()).onTapGesture {
                            if col == self.orderById {
                              if self.orderDescending {
                                self.orderDescending = false
                              } else {
                                self.orderById = nil
                              }
                            } else {
                              self.orderById = col
                              self.orderDescending = true
                            }
                            self.update()
                          }
                      }
    ) {
      (country, fact) -> AnyView in
      if let value = country[keyPath: fact.keyPath] {
        if let formattedValue = fact.format(value) {
          var resultStr = formattedValue.value
          if let unit = formattedValue.unit {
            resultStr += " \(unit)"
          }
          switch formattedValue.alignment {
          case .left:
            return AnyView(HStack {
              Text(resultStr)
              Spacer()
            })
          case .center:
            return AnyView(HStack {
              Text(resultStr)
          })
          case .right:
            return AnyView(HStack {
              Spacer()
              Text(resultStr)

          })
          }
        }
      }
      return AnyView(HStack { Text("N/A") })
    }.onAppear {
      // TODO: Move this to a table state
      self.filterUpdate = self.filterState.countriesDidChange.debounce(for: .milliseconds(5), scheduler: RunLoop.main).sink {
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
