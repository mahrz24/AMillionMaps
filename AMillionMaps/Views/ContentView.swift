//
//  ContentView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 30.06.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    HStack {
      ConfigView()
      VStack {
        MapView()
        Text("Table")
      }
    }
  
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
