//
//  AppDelegate+Injection.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 02.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation
import Resolver
import SQLite

extension Resolver: ResolverRegistering {
  public static func registerAllServices() {
    register(Connection.self) {
      guard let url = Bundle.main.url(forResource: "countries", withExtension: "db") else {
        fatalError("Failed to locate 'countries.db' in bundle.")
      }
      guard let db = try? Connection(url.absoluteString, readonly: true) else {
        fatalError("Could not open 'countries.db'")
      }
      return db
    }.scope(application)
    register { SQLCountryProvider(db: resolve()) as CountryProvider }.scope(application)
    register { FilterState() }.scope(application)
    register { ColorAndDataState() }.scope(application)
    register { SelectionViewState() }.scope(application)
    register { FilterSelectionState() }.scope(application)
  }
}
