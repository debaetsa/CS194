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
  case Code = 0
  case Item
  case Queue
  case Request
  case Image
}

enum SendableCode: UInt8 {
  case Version = 0         // followed by 1-byte version number
  case LibraryIdentifier   // followed by the bytes of a NSUUID
                           //    - to the client: implies Library change
                           //    - to the server: identifiers current Library
  case LibraryDone         // signals that the Library has finished sending

  var hasData: Bool {
    switch self {
    case .LibraryIdentifier: fallthrough
    case .Version:
      return true

    default:
      return false
    }
  }
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

  func getNextData(inout offset: Int) -> NSData? {
    guard let decodedDataLength = getNextInteger(&offset) else {
      return nil  // not enough bytes to get the length
    }
    let dataLength = Int(decodedDataLength)

    guard length >= (offset + dataLength) else {
      return nil  // not enough bytes to extract all the data
    }

    let range = NSMakeRange(offset, dataLength)
    offset += dataLength  // update offset after capturing range
    return subdataWithRange(range)
  }

  func getNextString(inout offset: Int) -> String? {
    guard let data = getNextData(&offset) else {
      return nil
    }

    return String(data: data, encoding: NSUTF8StringEncoding)
  }
  
  func getNextImage(inout offset: Int) -> UIImage? {
    guard let data = getNextData(&offset) else {
      return nil
    }

    return UIImage(data: data)
  }

  func getNextUUID(inout offset: Int) -> NSUUID? {
    guard length >= (offset + sizeof(uuid_t)) else {
      return nil  // not enough bytes for a UUID
    }

    offset += sizeof(uuid_t)

    // we have enough bytes to get the UUID, so create an instance from them
    return NSUUID(UUIDBytes: UnsafePointer(bytes))
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

  func appendCustomData(maybeData: NSData?) {
    appendCustomInteger(UInt32(maybeData?.length ?? 0))
    if let data = maybeData {
      appendData(data)
    }
  }

  func appendCustomString(string: String) {
    appendCustomData(string.dataUsingEncoding(NSUTF8StringEncoding))
  }

  func appendCustomImage(image: UIImage) {
    appendCustomData(UIImageJPEGRepresentation(image, 0.1))
  }
}

extension NSUUID {
  var data: NSData? {
    guard let data = NSMutableData(length: sizeof(uuid_t)) else {
      return nil
    }
    getUUIDBytes(UnsafeMutablePointer(data.mutableBytes))
    return data
  }
}