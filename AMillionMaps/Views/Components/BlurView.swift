//
//  BlurView.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 12.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
  let style: UIBlurEffect.Style

  func makeUIView(context _: UIViewRepresentableContext<BlurView>) -> UIView {
    let view = UIView(frame: .zero)
    view.backgroundColor = .clear
    let blurEffect = UIBlurEffect(style: style)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    view.insertSubview(blurView, at: 0)
    NSLayoutConstraint.activate([
      blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
      blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
    ])
    return view
  }

  func updateUIView(_: UIView,
                    context _: UIViewRepresentableContext<BlurView>) {}
}

struct BlurView_Previews: PreviewProvider {
  static var previews: some View {
    BlurView(style: .light)
  }
}
