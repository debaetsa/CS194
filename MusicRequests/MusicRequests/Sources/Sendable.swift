//
//  Sendable.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/16/16.
//
//

import Foundation
import UIKit

class UniqueGenerator {
  private var counter = UInt32(0)

  func next() -> UInt32 {
    ++counter
    return counter
  }
}

enum SendableIdentifier: UInt8 {
  case Item = 0
  case Queue
  case Request
  case Image
}

/** Applied to objects that can be serialized and sent over the network. */
protocol Sendable {

  /** Objects that are sendable must provide an identifier when being sent. */
  var sendableIdentifier: SendableIdentifier { get }

  /** Objects that are sendable must also provide the data to be sent. */
  var sendableData: NSData { get }

}


/////////////////////
// Data Extensions //
/////////////////////

// These extensions make it much easier to read and write integers and strings
// to the data objects.  This is how information is serialized in the app.

extension NSData {
  func getNextByte(inout offset: Int) -> UInt8? {
    var value = UInt8(0)

    let length = self.length
    guard length >= (offset + sizeofValue(value)) else {
      return nil  // we don't have a byte to load
    }

    withUnsafeMutablePointer(&value) {
      getBytes(UnsafeMutablePointer($0), range: NSMakeRange(offset, sizeofValue(value)))
    }

    offset += sizeofValue(value)

    return value
  }

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
    guard let decodedStringLength = getNextInteger(&offset) else {
      return nil  // we couldn't get the length, so we can't get the data
    }
    let stringLength = Int(decodedStringLength)  // cast it to an Int

    guard length >= (offset + stringLength) else {
      return nil  // we don't have enough bytes to read the string, so fail
    }

    let result = String(
      data: subdataWithRange(NSMakeRange(offset, stringLength)),
      encoding: NSUTF8StringEncoding
    )
    offset += Int(stringLength)
    return result
  }
  
  func getNextImage(inout offset: Int) -> UIImage? {
    guard let encodedImageLength = getNextInteger(&offset) else {
      return nil  // we couldn't get the length, so we can't get the data
    }

    let imageLength = Int(encodedImageLength)  // cast it to an Int
    
    guard length >= (offset + imageLength) else {
      return nil  // we don't have enough bytes to read the image, so fail
    }
    
    // actually grab the NSData corresponding to the UIImage
    let value = subdataWithRange(NSMakeRange(offset, imageLength))
    offset += Int(imageLength)
    return UIImage(data: value)
  }
}

extension NSMutableData {
  func appendByte(byte: UInt8) {
    var transformed = byte
    withUnsafePointer(&transformed) {
      appendBytes($0, length: sizeofValue(transformed))
    }
  }

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
    appendCustomInteger(length)

    // and then append the actual bytes if they exist
    if let data = maybeData {
      appendData(data)
    }
  }
}