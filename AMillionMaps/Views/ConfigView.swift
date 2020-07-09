//
//  ConfigView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI
import Resolver

struct ConfigView: View {
    var body: some View {
      ZStack {
        FilterView()
      }.frame(maxWidth: 250)
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView()
    }
}
