//
//  SelectionViewState.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 21.08.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import SwiftUI

enum PanelState {
  case hidden
  case visible(() -> AnyView)
}

class SelectionViewState: ObservableObject {
  @Published var leftSidePanelState: PanelState = .hidden
}
