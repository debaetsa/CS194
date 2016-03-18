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
      removeAllConnections()
      destroyListeningSocket()

      if broadcast {
        // start a new session if we need to broadcast something
        let port = initializeListeningSocket()
        logger("now listening on port \(port)")

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
  var sourceLibrary: Library {
    didSet {
      localQueue.sourceLibrary = sourceLibrary
      sendDidChangeLibraryNotification()
      sendLibraryToClients()
    }
  }

  /** This is where we return the relevant library for this object.

   It is used by the application when showing the "Library" view. */
  override var library: Library? {
    return sourceLibrary
  }

  override var queue: Queue? {
    return localQueue
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
  private var allClients = [Connection]()
  private var validClients = [Connection]()  // clients that have requested a Library
  private var clientRequests = [Connection: [Request]]()

  /** Stores the broadcasted NSNetService.

  It needs to be mutable so that it can be changed if the name is updated. */
  private var netService: NSNetService?

  func isLocalService(service: NSNetService) -> Bool {
    return netService == service
  }

  /** Stores the socket that is accepting connections for this device.
   
   We create and destroy the socket as broadcasting is enabled/disabled in
   order to save the battery as much as possible. */
  private var socket: CFSocket?

  /** Stores the listener for changes to the Queue.

   We send out Queue updates whenever it changes.  We might decrease the
   frequency of these updates depending on the data usage. */
  private var queueChangedListener: NSObjectProtocol?

  /** Stores the Queue that is used for this Session. */
  private var localQueue: LocalQueue {
    didSet {
      sendDidChangeQueueNotification()
    }
  }

  init(library: Library, queue: LocalQueue) {
    self.fullLibrary = library
    self.sourceLibrary = library
    self.currentQueueData = queue.sendableData
    self.localQueue = queue

    super.init()

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
      logger("failed to create stream for connection")
      return
    }

    // we want to close the native sockets when the streams are closed
    readStream.setProperty(kCFBooleanTrue, forKey: kCFStreamPropertyShouldCloseNativeSocket as String)
    writeStream.setProperty(kCFBooleanTrue, forKey: kCFStreamPropertyShouldCloseNativeSocket as String)

    // next, figure out the address as a string
    let port = Int(UInt16(bigEndian: from.sin_port))
    let address = String.fromCString(UnsafePointer(inet_ntoa(from.sin_addr)))!

    addClient(Connection(ipAddress: address, port: port, input: readStream, output: writeStream))
  }

  private func addClient(connection: Connection) {
    logger("new connection \(connection.address)")

    // add them to the list
    connection.onClosed = didCloseConnection
    connection.onReceivedData = didReceiveData
    connection.onReceivedCode = didReceiveCode
    allClients.append(connection)
    clientRequests[connection] = []
  }

  private func removeAllConnections() {
    for connection in allClients {
      connection.onClosed = nil
      connection.onReceivedCode = nil
      connection.onReceivedData = nil
      connection.close()
    }

    // clear out all of the objects
    allClients.removeAll()
    validClients.removeAll()
    clientRequests.removeAll()
  }

  private func sendLibraryData(toConnection connection: Connection) {
    // first send the entire contents of the Library
    for artist in sourceLibrary.allArtists {
      connection.sendItem(artist)
    }
    for album in sourceLibrary.allAlbums {
      connection.sendItem(album)
    }
    for genre in sourceLibrary.allGenres {
      connection.sendItem(genre)
    }
    for song in sourceLibrary.allSongs {
      connection.sendItem(song)
    }
    for playlist in sourceLibrary.allPlaylists {
      connection.sendItem(playlist)
    }
    connection.sendCode(.LibraryDone)
  }

  private func sendQueueData(toConnection connection: Connection) {
    // next, send the entire Queue
    connection.sendItem(localQueue, withCachedData: currentQueueData)
  }

  private func sendArtworkData(toConnection connection: Connection) {
    // finally, send all of the album artwork -- if needed
    var sentAlbumArtwork = Set<Album>()

    for song in localQueue.getAllQueueSongs() {
      if let album = song.album, let _ = album.image {
        connection.sendItem(CustomAlbumArt(albumInstance: album))
        sentAlbumArtwork.insert(album)
      }
    }

    // then the rest of the library
    for album in sourceLibrary.allAlbums {
      if let _ = album.image where !sentAlbumArtwork.contains(album) {
        connection.sendItem(CustomAlbumArt(albumInstance: album))
      }
    }
  }

  private func didCloseConnection(connection: Connection, didFail fail: Bool) {
    logger("\(connection.address) / failed: \(fail)")

    // stop paying attention to anything said by this client
    connection.onReceivedCode = nil
    connection.onReceivedData = nil
    connection.onClosed = nil

    // remove it from the list of allClients
    if let index = allClients.indexOf(connection) {
      allClients.removeAtIndex(index)
    }

    // remove it from the list of activeClients
    if let index = validClients.indexOf(connection) {
      validClients.removeAtIndex(index)
    }

    clientRequests.removeValueForKey(connection)
  }

  private func shouldSendLibrary(toIdentifier maybeIdentifier: NSData?) -> Bool {
    var offset = 0
    if let data = maybeIdentifier, let uuid = data.getNextUUID(&offset) {
      if uuid == sourceLibrary.globallyUniqueIdentifier {
        return false
      }
    }
    return true
  }

  private func sendLibraryToClients() {
    // We send the Library to all of the clients that have "authenticated."
    for connection in validClients {
      connection.sendCode(.LibraryIdentifier, withData: sourceLibrary.globallyUniqueIdentifier.data!)
      sendLibraryData(toConnection: connection)
      sendQueueData(toConnection: connection)
      sendArtworkData(toConnection: connection)
    }
  }

  private func respondToLibraryIdentifier(maybeIdentifier: NSData?, fromConnection connection: Connection) {
    let sendLibrary = shouldSendLibrary(toIdentifier: maybeIdentifier)

    if sendLibrary {
      connection.sendCode(.LibraryIdentifier, withData: sourceLibrary.globallyUniqueIdentifier.data!)
      sendLibraryData(toConnection: connection)
    }

    // we always need to send the updated Queue since that may be out of date
    sendQueueData(toConnection: connection)

    if sendLibrary {
      sendArtworkData(toConnection: connection)
    }
  }

  private func didReceiveCode(code: SendableCode, maybeData: NSData?, fromConnection connection: Connection) {
    switch code {
    case .LibraryIdentifier:
      respondToLibraryIdentifier(maybeData, fromConnection: connection)
      validClients.append(connection)  // this one is now considered valid

    default:
      break
    }
  }

  private func didReceiveData(data: NSData, withIdentifier identifier: SendableIdentifier, fromConnection connection: Connection) {
    switch identifier {
    case .Request:
      if let request = Request(data: data, library: sourceLibrary, queue: localQueue) {

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

        var previousVote = Request.Vote.None
        if let requests = clientRequests[connection] {
          // try to find the Index for the previous Request
          let maybeIndex = requests.indexOf({ $0.queueItem === queueItem })

          if let index = maybeIndex {
            // grab the vote
            previousVote = requests[index].vote

            // and then replace the request if we can
            clientRequests[connection]![index] = request

          } else {
            // otherwise, just add it to the list for the next iteration
            clientRequests[connection]!.append(request)
          }
        }

        let localQueueItem = (queueItem as! LocalQueueItem)

        // undo whatever was done previously
        switch previousVote {
        case .Up:   --localQueueItem.votes
        case .Down: ++localQueueItem.votes
        default: break
        }

        // and then apply whatever has been done now
        switch request.vote {
        case .Up:   ++localQueueItem.votes
        case .Down: --localQueueItem.votes
        default: break
        }

        // Refresh the display.  Wahoo!
        localQueue.refresh()

      } else {
        logger("failed to load request from data \(data)")
      }

    default:
      logger("ignoring data of type \(identifier)")
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
    let data = localQueue.sendableData
    guard currentQueueData != data else {
      return false  // the data didn't change, so don't send anything
    }
    currentQueueData = data

    for client in validClients {
      client.sendItem(localQueue, withCachedData: currentQueueData)
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
      return $0
    }
    context.release = {
      // release
      let contextPointer = UnsafeMutablePointer<ContextUserInfo>($0)
      --contextPointer.memory.retainCount

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
            return
          }

          // "data" is a CFSocketNativeHandle, meaning a file descriptor
          let acceptedSocketHandle = UnsafePointer<CFSocketNativeHandle>(data).memory

          // "remoteAddress" is a struct sockaddr for the connection
          var acceptedRemoteAddress = sockaddr_in()
          let minimumDataLength = sizeofValue(acceptedRemoteAddress)
          guard let dataForAddress = remoteAddress else {
            logger("no address received for remote connection")
            return
          }
          let dataLength = Int(CFDataGetLength(dataForAddress))
          guard dataLength >= minimumDataLength else {
            logger("not enough bytes received to parse address")
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
    logger("w.start NSNetService: \(sender)")
  }

  func netServiceDidPublish(sender: NSNetService) {
    logger("started NSNetService: \(sender)")
  }

  func netServiceDidStop(sender: NSNetService) {
    logger("stopped NSNetService: \(sender.name)")
  }

  func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
    logger("error   NSNetService: \(sender)")
  }

}
