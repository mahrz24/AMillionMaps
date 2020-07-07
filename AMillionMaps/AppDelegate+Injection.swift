//
//  AppDelegate+Injection.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
  public static func registerAllServices() {
    register { SQLCountryProvider() as CountryProvider }.scope(application)
    register { DefaultStatefulFilteredCountryProvider() as StatefulFilteredCountryProvider }.scope(application)
  }
}
