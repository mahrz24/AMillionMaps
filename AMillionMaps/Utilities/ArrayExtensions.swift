//
//  ArrayExtensions.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 03.08.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

extension Array {
  init(repeating: [Element], count: Int) {
    self.init([[Element]](repeating: repeating, count: count).flatMap { $0 })
  }

  func repeated(count: Int) -> [Element] {
    [Element](repeating: self, count: count)
  }
}
