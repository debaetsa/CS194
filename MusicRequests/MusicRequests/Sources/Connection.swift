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

  init(ipAddress: String, port: Int, input: NSInputStream, output: NSOutputStream) {
    self.inputStream = input
    self.outputStream = output
    self.address = (ipAddress, port)
    self.bytesToSend = NSMutableData()

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

  private func readAvailableData() {
    guard inputStream.hasBytesAvailable else {
      print("Ignoring read attempt since there are no bytes to read.")
      return
    }

    let size = 32
    let buffer = UnsafeMutablePointer<UInt8>.alloc(size)
    let read = inputStream.read(buffer, maxLength: size)
    if read > 0 {
      let message = String(bytesNoCopy: UnsafeMutablePointer(buffer), length: read, encoding: NSUTF8StringEncoding, freeWhenDone: false)
      print("\(address) received message: \(String(message))")
    }
    buffer.destroy()
    buffer.dealloc(size)
  }

  // MARK: - Write Handling

  func sendMessage(message: String) {
    if let data = message.dataUsingEncoding(NSUTF8StringEncoding) {
      bytesToSend.appendData(data)
      sendAvailableData()  // send data if there is space
    } else {
      print("Ignoring message since it could not be converted to UTF8.")
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
    print("\(address) wrote \(written) bytes")

    // TODO: Handle the case where written is -1.
    if written > 0 {
      // get rid of the bytes that we sent so that we don't send them again
      bytesToSend.replaceBytesInRange(NSMakeRange(0, written), withBytes: nil, length: 0)
    }
  }

}
