//
//  Sendable.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/16/16.
//
//

import Foundation

enum SendableIdentifier: UInt8 {
  case Item = 0
  case QueueItem
}

/** Applied to objects that can be serialized and sent over the network. */
protocol Sendable {

  /** Objects that are sendable must provide an identifier when being sent. */
  var sendableIdentifier: SendableIdentifier { get }

  /** Objects that are sendable must also provide the data to be sent. */
  var sendableData: NSData { get }

}

extension NSMutableData {
  func appendCustomInteger(value: UInt32) {
    var transformed = value.bigEndian
    withUnsafePointer(&transformed) {
      appendBytes(UnsafePointer($0), length: sizeofValue(transformed))
    }
  }


  func appendCustomString(string: String) {
    let maybeData = string.dataUsingEncoding(NSUTF8StringEncoding)

    // figure out the length
    var length = UInt32(0)
    if let data = maybeData {
      length = UInt32(data.length)
    }

    // append the length to the data
    length = length.bigEndian
    withUnsafePointer(&length) {
      appendBytes(UnsafePointer($0), length: sizeofValue(length))
    }

    // and then append the actual bytes if they exist
    if let data = maybeData {
      appendData(data)
    }
  }
}