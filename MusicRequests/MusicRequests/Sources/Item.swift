//
//  Item.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/30/16.
//
//

import UIKit

class Item: NSObject, Sendable {

  static var nextIdentifier: UInt32 = 1

  /** The identifier of the Item, used to maintain links across the network. */
  let identifier: UInt32

  // The name of the item (to be displayed).
  var name: String

  // The name of the item (for sorting purposes).  Should never be displayed.
  var sortName: String

  init(name: String, sortName: String) {
    self.name = name
    self.sortName = sortName
    self.identifier = Item.nextIdentifier
    ++Item.nextIdentifier

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
    case Item = 0
    case Artist
    case Album
    case Song
    case Genre
    case Playlist
  }

  /** This is which type of Item is being sent. */
  var tag: Tag {
    return .Item
  }

  // mark this as an "Item" when being sent
  var sendableIdentifier: SendableIdentifier {
    return .Item
  }

  func buildSendableData(mutableData: NSMutableData) {
    // first, write the type for this item
    var tag = self.tag
    withUnsafePointer(&tag) {
      mutableData.appendBytes(UnsafePointer($0), length: sizeofValue(tag))
    }

    // next, write the identifier for this Item
    var identifier = self.identifier.bigEndian
    withUnsafePointer(&identifier) {
      mutableData.appendBytes(UnsafePointer($0), length: sizeofValue(identifier))
    }

    // finally, write the strings for this item
    mutableData.appendCustomString(name)
    mutableData.appendCustomString(sortName)
  }

  // and serialize the data in some reasonable manner
  var sendableData: NSData {
    let data = NSMutableData()
    buildSendableData(data)
    return data
  }

  var currentDataIndex = 0

  init(data: NSData, lookup: [UInt32: Item]) {
    var offset = 1
    self.identifier = data.getNextInteger(&offset)!
    self.name = data.getNextString(&offset)!
    self.sortName = data.getNextString(&offset)!
    self.currentDataIndex = offset

    super.init()
  }

}

extension NSData {
  func getNextInteger(inout offset: Int) -> UInt32? {
    var value = UInt32(0)  // so that we can put it somewhere

    let length = self.length
    guard length >= (offset + sizeofValue(value)) else {
      return nil  // not enough to load an integer
    }

    // actually grab the integer
    withUnsafeMutablePointer(&value) {
      getBytes(UnsafeMutablePointer($0), range: NSMakeRange(offset, sizeofValue(value)))
    }
    value = UInt32(bigEndian: value)

    // then increment the offset
    offset += sizeofValue(value)

    return value
  }

  func getNextString(inout offset: Int) -> String? {
    guard let stringLength = getNextInteger(&offset) else {
      return nil  // we couldn't get the length, so we can't get the data
    }

    guard self.length >= (offset + Int(stringLength)) else {
      return nil  // we don't have enough bytes to read the string, so fail
    }

    let result = String(data: subdataWithRange(NSMakeRange(offset, Int(stringLength))), encoding: NSUTF8StringEncoding)
    offset += Int(stringLength)
    return result
  }
}