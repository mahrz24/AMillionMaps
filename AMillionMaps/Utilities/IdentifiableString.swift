//
//  IdentifiableString.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 25.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

extension String: Identifiable {
  public var id: String { self }
}
