//
//  Item.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/30/16.
//
//

import UIKit

protocol ShallowCopy {
  typealias ItemType

  /** Creates a very empty, basic copy of the Item.

   For example, if it's an Album, a new Album will be created without any Song
   references contained in it.  This allows entirely independent item graphs to
   be built. */
  func shallowCopy() -> ItemType
}

class Item: NSObject, Sendable {

  private static let idGenerator = UniqueGenerator()

  /** The identifier of the Item, used to maintain links across the network. */
  let identifier: UInt32

  // The name of the item (to be displayed).
  var name: String

  // The name of the item (for sorting purposes).  Should never be displayed.
  var sortName: String

  init(name: String, sortName: String) {
    self.name = name
    self.sortName = sortName
    self.identifier = Item.idGenerator.next()

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

  // MARK: - Sending

  enum Tag: UInt8 {
    case General = 0
    case Artist
    case Album
    case Song
    case Genre
    case Playlist
  }

  /** This is which type of Item is being sent. */
  var tag: Tag {
    return .General
  }

  // mark this as an "Item" when being sent
  var sendableIdentifier: SendableIdentifier {
    return .Item
  }

  func buildSendableData(mutableData: NSMutableData) {
    mutableData.appendByte(self.tag.rawValue)  // the type of object
    mutableData.appendCustomInteger(self.identifier)  // the ID for the object
    mutableData.appendCustomString(name)  // the name
    mutableData.appendCustomString(sortName)  // and the sortName
  }

  /** Serialize the data by calling the function.

   This allows the data to be constructed in a single mutable object rather
   than continually constructing immutable objects (or by using evil casts). */
  var sendableData: NSData {
    let data = NSMutableData()
    buildSendableData(data)
    return data
  }

  required init?(data: NSData, lookup: [UInt32: Item], inout offset: Int) {
    var failed = false

    var identifier = UInt32(0)
    if let boundIdentifier = data.getNextInteger(&offset) {
      identifier = boundIdentifier
    } else {
      failed = true
    }
    self.identifier = identifier

    var name = ""
    if !failed {
      if let boundName = data.getNextString(&offset) {
        name = boundName
      } else {
        failed = true
      }
    }
    self.name = name

    var sortName = ""
    if !failed {
      if let boundSortName = data.getNextString(&offset) {
        sortName = boundSortName
      } else {
        failed = true
      }
    }
    self.sortName = sortName

    super.init()

    guard !failed else {
      return nil
    }
  }

}
