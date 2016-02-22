//
//  RemoteSession.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class RemoteSession: Session, NSNetServiceDelegate {

  /** Stores the netService, meant to be used only by the manager. */
  let netService: NSNetService

  /** Stores the name of the session, as set by the remote user. */
  let name: String

  /** Stores the current connection to this particular server. */
  var connection: Connection?

  /** Stores the data objects received into the Library. */
  let remoteLibrary: RemoteLibrary

  init(netService: NSNetService) {
    self.netService = netService
    self.name = netService.name
    self.remoteLibrary = RemoteLibrary()

    // TODO: Create a Queue() specifically for this remote session.  Just know
    // that it will probably not be populated until it is actually accessed.
    let queue = RemoteQueue(library: remoteLibrary)
    super.init(queue: queue)
    queue.remoteSession = self

    // set the delegate after the super.init() call
    self.netService.delegate = self
  }

  override var library: Library! {
    return remoteLibrary
  }


  /** Attempts to connect to the service.

   Returns true if everything went well so far, but note that it's still
   possible for the connection to fail at a later point. */
  func connect() -> Bool {
    // TODO: Maybe this should throw an error instead of returning a Bool.

    var maybeInputStream: NSInputStream?
    var maybeOutputStream: NSOutputStream?

    let result = withUnsafeMutablePointers(&maybeInputStream, &maybeOutputStream) {
      self.netService.getInputStream($0, outputStream: $1)
    }

    guard result else {
      print("Could not create the streams for the connection.")
      return false
    }

    guard let inputStream = maybeInputStream, outputStream = maybeOutputStream else {
      print("Did not get actual stream objects.")
      return false
    }

    // we should have been able to open the connection
    let connection = Connection(ipAddress: "", port: 0, input: inputStream, output: outputStream)
    connection.onReceivedData = didReceiveData
    self.connection = connection

    // and then let the caller know that this has mostly worked
    return true
  }

  func didReceiveData(type: SendableIdentifier, data: NSData) {
    switch type {
    case .Item:
      remoteLibrary.addItemFromData(data)

    case .Queue:
      queue.updateFromData(data, usingLibrary: remoteLibrary)

    default:
      print("Ignoring: \(data)")
    }
  }

  func netServiceWillResolve(sender: NSNetService) {
    print("About to resolve \(sender).")
  }

  func netServiceDidResolveAddress(sender: NSNetService) {
    print("Resolved address for \(sender): \(sender.addresses)")
  }

  func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
    print("Encountered error while resolving: \(errorDict)")
  }

}
