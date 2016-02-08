//
//  Item.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/30/16.
//
//

import UIKit

class Item: NSObject {

  // The name of the item (to be displayed).
  var name: String

  // The name of the item (for sorting purposes).  Should never be displayed.
  var sortName: String

  init(name: String, sortName: String) {
    self.name = name
    self.sortName = sortName

    super.init()
  }

  convenience init(name: String) {
    self.init(name: name, sortName: name)
  }

  /** Returns the sort value for some "Item." */
  static func sorter(first: Item, second: Item) -> Bool {
    return first.name.localizedCompare(second.name) == NSComparisonResult.OrderedAscending
  }

  func didFinishImporting() {
  }

}
