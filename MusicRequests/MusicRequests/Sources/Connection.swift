//
//  ClientConnection.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/16/16.
//
//

import UIKit

class Connection: NSObject, NSStreamDelegate {

  // store this for reference and determining unique connections
  let address: (ip: String, port: Int)

  // we need the streams to be able to send/receive data
  let inputStream: NSInputStream
  let outputStream: NSOutputStream

  // keep track of the bytes that we need to send to each client
  var bytesToSend: NSMutableData
  var bytesToProcess: NSMutableData

  // called to allow the received data to be processed
  var onReceivedData: ((SendableIdentifier, NSData) -> Void)?

  init(ipAddress: String, port: Int, input: NSInputStream, output: NSOutputStream) {
    self.inputStream = input
    self.outputStream = output
    self.address = (ipAddress, port)
    self.bytesToSend = NSMutableData()
    self.bytesToProcess = NSMutableData()

    super.init()

    prepare()
  }

  func prepare() {
    prepareStream(inputStream)
    prepareStream(outputStream)
  }

  func prepareStream(stream: NSStream) {
    stream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    stream.delegate = self
    stream.open()
  }

  // MARK: - Stream Delegate

  func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
    if (aStream === inputStream) {
      // we should process the incoming data
      handleInputEvent(eventCode)

    } else {
      // we should process the outgoing data
      handleOutputEvent(eventCode)
    }
  }

  private func handleInputEvent(eventCode: NSStreamEvent) {
    switch eventCode {
    case NSStreamEvent.OpenCompleted:
      print("\(address) finished opening the input stream.")

    case NSStreamEvent.HasBytesAvailable:
      print("\(address) has bytes available to read.")
      readAvailableData()

    default:
      break
    }
  }

  private func handleOutputEvent(eventCode: NSStreamEvent) {
    switch eventCode {
    case NSStreamEvent.OpenCompleted:
      print("\(address) finished opening the output stream.")

    case NSStreamEvent.HasSpaceAvailable:
      print("\(address) has space available to write.")
      sendAvailableData()  // send data if there is data to send

    default:
      break
    }
  }

  // MARK: - Read Handling

  // we only process on the main thread, so we can easily reuse this structure
  private static let bufferLength = 1024
  private static let buffer = UnsafeMutablePointer<UInt8>.alloc(bufferLength)

  private func readAvailableData() {
    guard inputStream.hasBytesAvailable else {
      print("Ignoring read attempt since there are no bytes to read.")
      return
    }

    let read = inputStream.read(Connection.buffer, maxLength: Connection.bufferLength)
    if read > 0 {
      // put it in a data object
      let data = NSData(
        bytesNoCopy: UnsafeMutablePointer(Connection.buffer),
        length: read,
        freeWhenDone: false
      )

      // and add it to the data that needs to be processed
      bytesToProcess.appendData(data)
    }
    Connection.buffer.destroy()  // get rid of what we put in there since it doesn't matter
    processAvailableItems()
  }

  private func processAvailableItems() {
    while true {
      let length = bytesToProcess.length
      guard length > 0 else {
        return  // there are no bytes to process, so stop processing
      }

      var itemType: SendableIdentifier = .Item
      var itemLength: UInt32 = 0

      // make sure we have enough to extract these types
      let minimumDataLength = sizeofValue(itemType) + sizeofValue(itemLength)
      guard length >= minimumDataLength else {
        return  // we can't find the type and length, so wait for more data
      }

      // figure out the length of received data
      withUnsafeMutablePointer(&itemLength) {
        bytesToProcess.getBytes(UnsafeMutablePointer($0), range: NSMakeRange(sizeofValue(itemType), sizeofValue(itemLength)))
      }
      itemLength = UInt32(bigEndian: itemLength)

      // now make sure we have received enough to extract this entire item
      guard length >= (Int(itemLength) + minimumDataLength) else {
        return  // need to wait for more data
      }

      // figure out the item type so that we can dispatch to the loader
      withUnsafeMutablePointer(&itemType) {
        bytesToProcess.getBytes(UnsafeMutablePointer($0), range: NSMakeRange(0, sizeofValue(itemType)))
      }

      // extract it, print it, and then remove it
      let data = bytesToProcess.subdataWithRange(NSMakeRange(minimumDataLength, Int(itemLength)))

      // pass that object as appropriate
      if let callback = onReceivedData {
        callback(itemType, data)
      }

      bytesToProcess.replaceBytesInRange(NSMakeRange(0, minimumDataLength + Int(itemLength)), withBytes: nil, length: 0)
    }
  }

  // MARK: - Write Handling

  func sendItem(item: Sendable) {
    sendItem(item, withCachedData: nil)
  }

  /** Sends the Sendable, but uses the cached data.

   This is intended to avoid running the same code repeatedly when sending the
   same thing to every client. */
  func sendItem(item: Sendable, withCachedData cachedData: NSData?) {
    // write the identifier
    bytesToSend.appendByte(item.sendableIdentifier.rawValue)

    // then write the data length and actual data
    let data = cachedData ?? item.sendableData
    bytesToSend.appendCustomInteger(UInt32(data.length))
    bytesToSend.appendData(data)

    sendAvailableData()
  }

  private func sendAvailableData() {
    let count = bytesToSend.length
    guard count > 0 else {
      return  // nothing left to send
    }

    let space = outputStream.hasSpaceAvailable
    guard space else {
      return  // no space available to write anything
    }

    // write as many bytes as possible
    let written = outputStream.write(UnsafePointer(bytesToSend.bytes), maxLength: count)
    print("\(address) wrote \(written) bytes")

    // TODO: Handle the case where written is -1.
    if written > 0 {
      // get rid of the bytes that we sent so that we don't send them again
      bytesToSend.replaceBytesInRange(NSMakeRange(0, written), withBytes: nil, length: 0)
    }
  }

}
