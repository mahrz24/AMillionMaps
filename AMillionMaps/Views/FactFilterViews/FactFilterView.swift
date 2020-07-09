//
//  FactFilterView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 03.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI


struct FactFilterView: View {
  let fact: Fact
  let action: (ConditionValue) -> Void

  var body: some View {
      switch self.fact.type {
      case .Constant(.numeric):
        return AnyView(NumericFactFilterView(fact: self.fact, action: self.action).frame(width: 180.0).padding(10))
      default:
        return AnyView(Text("Unknown Fact Type"))
      }
  }
}

//struct FactFilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FactFilterView()
//    }
//}
