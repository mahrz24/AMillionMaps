//
//  NumberFormatting.swift
//  AMillionMaps
//
//  Created by Malte Klemm on 09.07.20.
//  Copyright © 2020 Malte Klemm. All rights reserved.
//

import Foundation

extension Double {

    func truncate(places: Int) -> Double {

        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal

    }
  
  func formatTruncated(places: Int) -> String {
    if places == 0 {
      return "\(Int(self.truncate(places: 0)))"
    } else {
      return "\(self.truncate(places: places))"
    }
  }

}

func formatNumber(_ n: Int) -> String {
  return formatNumber(Double(n))
}

func formatNumber(_ n: Double, truncate: Int = 3) -> String {

    let num = abs(Double(n))
    let sign = (n < 0) ? "-" : ""

    switch num {

    case 1_000_000_000...:
        let formatted = num / 1_000_000_000
        return "\(sign)\(formatted.formatTruncated(places: min(max(truncate, 1), 3)))B"

    case 1_000_000...:
        let formatted = num / 1_000_000
        return "\(sign)\(formatted.formatTruncated(places: min(max(truncate, 1), 3)))M"

    case 1_000...:
        let formatted = num / 1_000
        return "\(sign)\(formatted.formatTruncated(places: min(max(truncate, 1), 3)))K"

    default:
        return "\(sign)\(num.formatTruncated(places: truncate))"

    }

}
