//
//  SelectionView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 21.08.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Resolver
import SwiftUI

struct SidePanelButton<Content: View, PanelContent: View>: View {
  @ObservedObject var selectionViewModel: SelectionViewState = Resolver.resolve()

  let panelBuilder: () -> PanelContent
  let viewBuilder: () -> Content

  init(@ViewBuilder panelBuilder: @escaping () -> PanelContent, _ viewBuilder: @escaping () -> Content) {
    self.panelBuilder = panelBuilder
    self.viewBuilder = viewBuilder
  }

  func anyPanelBuilder() -> AnyView {
    AnyView(panelBuilder())
  }

  var body: some View {
    Button(action: { withAnimation(.easeInOut) {
      self.selectionViewModel.leftSidePanelState = .visible(self.anyPanelBuilder)
      }
      }) {
        VStack {
          viewBuilder()
        }
    }
  }
}

// struct SelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectionView()
//    }
// }
