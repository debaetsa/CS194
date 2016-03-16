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
  private var maybeRemoteLibrary: RemoteLibrary? = nil {
    didSet {
      sendDidChangeLibraryNotification()

      if let remoteLibrary = maybeRemoteLibrary {
        // We just set a new RemoteLibrary, so update the Queue as well.
        let queue = RemoteQueue(library: remoteLibrary)
        queue.remoteSession = self
        maybeRemoteQueue = queue

      } else {
        // We cleared the RemoteLibrary, so also clear the Queue.
        maybeRemoteQueue = nil
      }
    }
  }

  private var maybeRemoteQueue: RemoteQueue? = nil {
    didSet {
      sendDidChangeQueueNotification()
    }
  }

  init(netService: NSNetService) {
    self.netService = netService
    self.name = netService.name

    super.init()

    // set the delegate after the super.init() call
    self.netService.delegate = self
  }

  override var library: Library? {
    return maybeRemoteLibrary
  }

  override var queue: Queue? {
    return maybeRemoteQueue
  }

  func disconnect() {
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
    connection.onReceivedCode = didReceiveCode
    self.connection = connection

    // and then let the caller know that this has mostly worked
    return true
  }

  func didReceiveData(data: NSData, ofType type: SendableIdentifier, fromConnection connection: Connection) {
    guard let remoteLibrary = maybeRemoteLibrary else {
      print("No Library; Ignoring \(data)")
      return
    }

    switch type {
    case .Item:
      remoteLibrary.addItemFromData(data)

    case .Image:
      remoteLibrary.updateFromData(data, usingLibrary: remoteLibrary)

    case .Queue:
      guard let remoteQueue = maybeRemoteQueue else {
        print("No Queue; Ignoring \(data)")
        return
      }
      remoteQueue.updateFromData(data, usingLibrary: remoteLibrary)

    default:
      print("Ignoring: \(data)")
    }
  }

  func didReceiveCode(code: SendableCode, withData maybeData: NSData?, fromConnection connection: Connection) {
    switch code {
    case .LibraryIdentifier:
      guard let data = maybeData else {
        print("LibraryIdentifier: no data")
        return
      }
      var offset = 0
      guard let uuid = data.getNextUUID(&offset) else {
        print("LibraryIdentifier: no UUID")
        return
      }

      // Create the RemoteLibrary that will receive the songs that are sent.
      maybeRemoteLibrary = RemoteLibrary(receivedGloballyUniqueIdentifier: uuid)

    default:
      print("Code: \(code); Data: \(maybeData)")
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
