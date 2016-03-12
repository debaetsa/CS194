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
  var onReceivedCode: ((SendableCode, NSData?) -> Void)?
  var onClosed: ((Connection, didFail: Bool) -> Void)?

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

  private func close() {
    inputStream.close()
    outputStream.close()
  }

  private func closeOnError(didFail didFail: Bool) {
    if let callback = onClosed {
      callback(self, didFail: didFail)  // report that it closed
    }
    close()  // end the communication
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

    guard read > 0 else {
      closeOnError(didFail: (read < 0))
      return  // can't read if this failed
    }

    // add it to the data that needs to be processed
    bytesToProcess.appendBytes(UnsafePointer(Connection.buffer), length: read)
    Connection.buffer.destroy()  // get rid of what we put in there since it doesn't matter

    processAvailableItems()
  }

  private func tryToProcessCode(inout offset: Int) -> Bool {
    guard let codeByte = bytesToProcess.getNextByte(&offset) else {
      return false  // don't have enough data to extract the information
    }

    guard let code = SendableCode(rawValue: codeByte) else {
      closeOnError(didFail: true)  // close it
      return false
    }

    var data: NSData? = nil
    if code.hasData {
      guard let processedData = bytesToProcess.getNextData(&offset) else {
        return false
      }
      data = processedData
    }

    if let callback = onReceivedCode {
      callback(code, data)
    }

    return true
  }

  private func tryToProcessData(ofType type: SendableIdentifier, inout withOffset offset: Int) -> Bool {
    // get the relevant data object
    guard let data = bytesToProcess.getNextData(&offset) else {
      return false
    }

    // pass that object as appropriate
    if let callback = onReceivedData {
      callback(type, data)
    }

    return true  // because we were able to process the Item
  }

  private func processAvailableItems() {
    while true {
      var offset = 0
      guard let itemTypeByte = bytesToProcess.getNextByte(&offset) else {
        return  // there was no byte to process, so stop processing
      }
      guard let itemType = SendableIdentifier(rawValue: itemTypeByte) else {
        closeOnError(didFail: true)
        return  // we got a bad identifier, so terminate the connection
      }

      switch itemType {
      case .Code:
        if !tryToProcessCode(&offset) {
          return
        }

      default:
        if !tryToProcessData(ofType: itemType, withOffset: &offset) {
          return
        }
      }

      // if we were able to process an item, delete the data
      bytesToProcess.replaceBytesInRange(NSMakeRange(0, offset), withBytes: nil, length: 0)
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
    bytesToSend.appendCustomData(cachedData ?? item.sendableData)

    sendAvailableData()
  }

  func sendCode(code: SendableCode, withData maybeData: NSData? = nil) {
    bytesToSend.appendByte(SendableIdentifier.Code.rawValue)
    bytesToSend.appendByte(code.rawValue)

    if let data = maybeData {
      bytesToSend.appendCustomData(data)
    }
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

    // TODO: Handle the case where written is -1.
    if written > 0 {
      // get rid of the bytes that we sent so that we don't send them again
      bytesToSend.replaceBytesInRange(NSMakeRange(0, written), withBytes: nil, length: 0)
    }
  }

}
