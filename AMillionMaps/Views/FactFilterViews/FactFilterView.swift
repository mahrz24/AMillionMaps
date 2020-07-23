//
//  FactFilterView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 03.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct FactFilterView: View {
  let fact: AnyFact
  let action: (ConditionValue) -> Void

  var body: some View {
    switch self.fact.type {
    case .Constant(.numeric):
      return AnyView(NumericFactFilterView(fact: self.fact.unwrap(), action: self.action))
    default:
      return AnyView(Text("Unknown Fact Type"))
    }
  }
}

// struct FactFilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FactFilterView()
//    }
// }
