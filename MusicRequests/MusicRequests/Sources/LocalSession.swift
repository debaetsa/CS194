//
//  LocalSession.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class LocalSession: Session, NSNetServiceDelegate {

  /** Whether or not the session should be broadcast on the network.

   If "false", then the app can be used in a "local playback only" mode. */
  var broadcast: Bool = false {
    didSet {
      if broadcast == oldValue {
        return  // the value didn't change so there is nothing to do
      }

      netService = nil
      destroyListeningSocket()

      if broadcast {
        // start a new session if we need to broadcast something
        let port = initializeListeningSocket()
        print("Created listening socket on port \(port).")

        // and then create the object that will make it available
        let service = LocalSession.createNetServiceForName(name, port: port)
        service.delegate = self
        service.publish()
        netService = service
      }
    }
  }

  /** Whether or not listeners can request songs.

   Setting this to "false" means that listeners can see all the upcoming songs
   but cannot upvote/downvote or request songs. */
  var acceptRequests: Bool = false

  /** This is the entire library, not the library sourcing songs. */
  let fullLibrary: Library

  /** This is the library that is being broadcast.

   It will generally be some subset of the fullLibrary, though it could very
   well be the entire library.  If a user selects a playlist, we'll construct a
   library out of that playlist. */
  var sourceLibrary: Library

  /** This is where we return the relevant library for this object.

   It is used by the application when showing the "Library" view. */
  override var library: Library! {
    return sourceLibrary
  }

  /** This is the name of the session being broadcast.

   If the value is set to the empty string, then the default name of the device
   will be broadcast. */
  var name: String = ""

  /** This is the password used to access the session.

   The value is currently ignored, and the requirement is not enforced.  The
   value is required, and an empty string for a password is basically the
   equivalent of not having a password.  In this situation, this is fine since
   it doesn't make sense to allow empty passwords to be valid passwords.  If we
   ask someone to enter a password, they should actually enter something. */
  var password: String = ""

  /** Stores all the clients who are currently connected. */
  private var clients = [Connection]()

  /** Stores the broadcasted NSNetService.

  It needs to be mutable so that it can be changed if the name is updated. */
  private var netService: NSNetService?

  /** Stores the socket that is accepting connections for this device.
   
   We create and destroy the socket as broadcasting is enabled/disabled in
   order to save the battery as much as possible. */
  private var socket: CFSocket?

  /** Stores the listener for changes to the Queue.

   We send out Queue updates whenever it changes.  We might decrease the
   frequency of these updates depending on the data usage. */
  private var queueChangedListener: NSObjectProtocol?

  private var localQueue: LocalQueue {
    return queue as! LocalQueue
  }

  init(library: Library, queue: LocalQueue) {
    self.fullLibrary = library
    self.sourceLibrary = library
    self.currentQueueData = queue.sendableData

    super.init(queue: queue)

    let center = NSNotificationCenter.defaultCenter()
    queueChangedListener = center.addObserverForName(Queue.didChangeNowPlayingNotification, object: queue, queue: nil) {
      [unowned self] (note) in

      // when the Queue changes, check if we need to send the updated version
      self.sendQueueIfNeeded()
    }
  }

  deinit {
    if let listener = queueChangedListener {
      NSNotificationCenter.defaultCenter().removeObserver(listener)
    }
  }

  // MARK: - Clients

  func receivedNewConnection(from: sockaddr_in, withNativeSocketHandle handle: CFSocketNativeHandle) {
    // the results will be passed back via these variables
    var unmanagedReadStream: Unmanaged<CFReadStream>?
    var unmanagedWriteStream: Unmanaged<CFWriteStream>?

    withUnsafeMutablePointers(&unmanagedReadStream, &unmanagedWriteStream) {
      CFStreamCreatePairWithSocket(nil, handle, $0, $1)
    }

    let maybeReadStream = unmanagedReadStream?.takeRetainedValue() as NSInputStream?
    let maybeWriteStream = unmanagedWriteStream?.takeRetainedValue() as NSOutputStream?

    guard let readStream = maybeReadStream, writeStream = maybeWriteStream else {
      print("Could not create the streams for the connection.")
      return
    }

    // next, figure out the address as a string
    let port = Int(UInt16(bigEndian: from.sin_port))
    let address = String.fromCString(UnsafePointer(inet_ntoa(from.sin_addr)))!

    addClient(Connection(ipAddress: address, port: port, input: readStream, output: writeStream))
  }

  private func addClient(connection: Connection) {
    // add them to the list
    connection.onClosed = didCloseConnection
    connection.onReceivedData = didReceiveData
    clients.append(connection)

    // and then send them the contents of the entire library
    for artist in sourceLibrary.allArtists {
      connection.sendItem(artist)
    }
    for album in sourceLibrary.allAlbums {
      connection.sendItem(album)
    }
    for song in sourceLibrary.allSongs {
      connection.sendItem(song)
    }

    // send the Queue (once all the songs are known)
    connection.sendItem(queue, withCachedData: currentQueueData)
    
    // and finally send compressed images
    for album in sourceLibrary.allAlbums {
      connection.sendItem(CustomAlbumArt(albumInstance: album))
    }
  }

  private func didCloseConnection(connection: Connection, didFail fail: Bool) {
    print("Removed client \(connection) with failure \(fail).")

    var indexOfClient: Int?
    for (index, client) in clients.enumerate() {
      if client === connection {
        indexOfClient = index
        break
      }
    }
    if let index = indexOfClient {
      clients.removeAtIndex(index)
    }
  }

  private func didReceiveData(identifier: SendableIdentifier, data: NSData) {
    switch identifier {
    case .Request:
      if let request = Request(data: data, lookup: (sourceLibrary as! AppleLibrary).lookup, queue: queue) {

        let queueItem: QueueItem

        if let boundQueueItem = request.queueItem {
          queueItem = boundQueueItem

        } else {
          // We got a Request for something that isn't in the Queue.  Add it to
          // the Queue so that we can update it.
          queueItem = localQueue.createUpcomingItemForSong(request.song!)

          // And also associate it with the Request.
          request.queueItem = queueItem
        }


        // Now that we have the QueueItem for this Request, figure out if the
        // response changed.  For now, just increment/decrement for up/down.
        ++(queueItem as! LocalQueueItem).votes

        // Refresh the display.  Wahoo!
        localQueue.refresh()

      } else {
        print("Could not load Request from data \(data).")
      }

    default:
      print("Ignoring data of type \(identifier).")
    }
  }

  // MARK: - Sending the Queue

  // We only want to send the Queue when it changes, so we store what we last
  // sent and compare it to what we are about to send.  We only need to send it
  // when the data object is different.  This also gives a quick way to send
  // the Queue when a new client connects.

  private var currentQueueData: NSData

  /** Sends the Queue data if it has changed.

   Returns whether or not the data was sent. */
  func sendQueueIfNeeded() -> Bool {
    let data = queue.sendableData
    guard currentQueueData != data else {
      return false  // the data didn't change, so don't send anything
    }
    currentQueueData = data

    for client in clients {
      client.sendItem(queue, withCachedData: currentQueueData)
    }

    return true
  }

  // MARK: - Socket

  func destroyListeningSocket() {
    if let socket = self.socket {
      CFSocketInvalidate(socket)
      self.socket = nil  // get rid of the reference after clearing it
    }
  }

  struct ContextUserInfo {
    var retainCount: Int = 0
    var localSession: LocalSession
  }

  /** Creates the listening socket and returns the port.

  Will return nil if a port couldn't be created. */
  func initializeListeningSocket() -> UInt16 {
    assert(socket == nil)  // there must not be a socket when we initialize it

    // create the self pointer used to get back to this object from the socket
    let selfPointer = UnsafeMutablePointer<ContextUserInfo>.alloc(1)
    selfPointer.initialize(ContextUserInfo(retainCount: 0, localSession: self))

    var context = CFSocketContext()
    context.version = CFIndex(0)
    context.info = UnsafeMutablePointer(selfPointer)

    context.retain = {
      // retain
      let contextPointer = UnsafeMutablePointer<ContextUserInfo>($0)
      ++contextPointer.memory.retainCount
      print("Retain Count: ^ \(contextPointer.memory.retainCount)")
      return $0
    }
    context.release = {
      // release
      let contextPointer = UnsafeMutablePointer<ContextUserInfo>($0)
      --contextPointer.memory.retainCount
      print("Retain Count: _ \(contextPointer.memory.retainCount)")

      if contextPointer.memory.retainCount == 0 {
        contextPointer.destroy()
        contextPointer.dealloc(1)  // free the memory
      }
    }

    // create the socket
    withUnsafePointer(&context, { (contextPointer) -> Void in
      socket = CFSocketCreate(
        nil,
        PF_INET,
        SOCK_STREAM,
        IPPROTO_TCP,
        CFSocketCallBackType.AcceptCallBack.rawValue,
        { (socket: CFSocket!, type: CFSocketCallBackType, remoteAddress: CFData!, data: UnsafePointer<Void>, userInfo: UnsafeMutablePointer<Void>) in
          // make sure that this is actually a new connection request
          guard type == CFSocketCallBackType.AcceptCallBack else {
            print("Ignoring callback of type \(type).")
            return
          }

          // "data" is a CFSocketNativeHandle, meaning a file descriptor
          let acceptedSocketHandle = UnsafePointer<CFSocketNativeHandle>(data).memory

          // "remoteAddress" is a struct sockaddr for the connection
          var acceptedRemoteAddress = sockaddr_in()
          let minimumDataLength = sizeofValue(acceptedRemoteAddress)
          guard let dataForAddress = remoteAddress else {
            print("Did not receive an address for the remote connection.")
            return
          }
          let dataLength = Int(CFDataGetLength(dataForAddress))
          guard dataLength >= minimumDataLength else {
            print("Did not receive enough bytes to build an address.")
            return
          }
          // store the bytes in the struct so that we can access them
          withUnsafeMutablePointer(&acceptedRemoteAddress) {
            CFDataGetBytes(dataForAddress, CFRange(location: CFIndex(0), length: CFIndex(dataLength)), UnsafeMutablePointer($0))
          }

          // get the corresponding LocalSession and forward the message
          let localSession = UnsafePointer<ContextUserInfo>(userInfo).memory.localSession
          localSession.receivedNewConnection(acceptedRemoteAddress, withNativeSocketHandle: acceptedSocketHandle)
        },
        contextPointer
      )
    })

    // prepare the structure used for binding the address
    var addr = sockaddr_in()
    addr.sin_len = UInt8(sizeofValue(addr))
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = in_port_t(0).bigEndian  // let the system choose a port
    addr.sin_addr = in_addr(s_addr: in_addr_t(0).bigEndian)

    // start responding to connection requests
    CFSocketSetAddress(socket, withUnsafePointer(&addr, {
      CFDataCreate(nil, UnsafePointer($0), CFIndex(addr.sin_len))
    }))
    CFRunLoopAddSource(CFRunLoopGetCurrent(), CFSocketCreateRunLoopSource(nil, socket, CFIndex(0)), kCFRunLoopDefaultMode)

    // now that we've bound the socket to a port, figure out the address
    let addressData = CFSocketCopyAddress(socket)
    withUnsafeMutablePointer(&addr, {
      CFDataGetBytes(addressData, CFRange(location: CFIndex(0), length: CFIndex(addr.sin_len)), UnsafeMutablePointer($0))
    })

    return UInt16(bigEndian: addr.sin_port)
  }

  // MARK: - NSNetService

  static func createNetServiceForName(name: String, port: UInt16) -> NSNetService {
    return NSNetService(domain: "", type: netServiceType, name: name, port: Int32(port))
  }

  func netServiceWillPublish(sender: NSNetService) {
    print("w.Start NSNetService: \(sender)")
  }

  func netServiceDidPublish(sender: NSNetService) {
    print("Started NSNetService: \(sender)")
  }

  func netServiceDidStop(sender: NSNetService) {
    print("Stopped NSNetService: \(sender.name)")
  }

  func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
    print("Error   NSNetService: \(sender)")
  }

}
