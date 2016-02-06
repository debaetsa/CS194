//
//  Pluralize.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/5/16.
//
//

import Foundation

// This is how we define the words that make something plural.
typealias Plural = (singular: String, plural: String)

extension Int {

  private static let formatter = NSNumberFormatter()

  func pluralize(plural: Plural) -> String {
    let formattedNumber = Int.formatter.stringFromNumber(NSNumber(integer: self))!

    return "\(formattedNumber) " + ((self == 1) ? plural.singular : plural.plural)
  }

}
