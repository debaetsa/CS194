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
      netService.stop()  // stop anything that's in progress

      if broadcast {
        // start a new session if we need to broadcast something
        netService = LocalSession.createNetServiceForName(name, port: port)
        netService.delegate = self
        netService.publish()
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

  /** Stores the broadcasted NSNetService.

  It needs to be mutable so that it can be changed if the name is updated. */
  private var netService: NSNetService

  /** Stores the socket that is accepting connections for this device. */
  private var socket: CFSocket! = nil

  /** Stores the port where the service is being offered.

   This is given to Bonjour to allow the discovery mechanism to connect to the
   library that is being broadcast. */
  private var port: UInt16!

  /** Stores all the clients who are currently connected. */
  private var clients = [Connection]()

  init(library: Library, queue: Queue) {
    self.fullLibrary = library
    self.sourceLibrary = library
    self.netService = LocalSession.createNetServiceForName("", port: 0)

    super.init(queue: queue)

    createListeningSocket()  // start listening regardless
  }

  var someObject = NSObject()

  func createListeningSocket() {
    var socket: CFSocket?  // must be optional to allow getting the address

    var context = CFSocketContext()
    let pointerToSelf = UnsafeMutablePointer<LocalSession>.alloc(1)
    pointerToSelf.initialize(self)
    context.info = UnsafeMutablePointer(pointerToSelf)

    withUnsafePointer(&context, { (pointer: UnsafePointer<CFSocketContext>) -> Void in
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
          let localSession = UnsafePointer<LocalSession>(userInfo).memory
          localSession.receivedNewConnection(acceptedRemoteAddress, withNativeSocketHandle: acceptedSocketHandle)
        },
        pointer
      )
    })
    self.socket = socket!  // the socket must exist

    var addr = sockaddr_in()
    addr.sin_len = UInt8(sizeof(sockaddr_in))
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = in_port_t(0).bigEndian
    addr.sin_addr = in_addr(s_addr: in_addr_t(0).bigEndian)

    CFSocketSetAddress(socket, withUnsafePointer(&addr, {
      CFDataCreate(nil, UnsafePointer($0), CFIndex(addr.sin_len))
    }))
    CFRunLoopAddSource(CFRunLoopGetCurrent(), CFSocketCreateRunLoopSource(nil, socket, CFIndex(0)), kCFRunLoopDefaultMode)

    // now that we've bound the socket to a port, figure out the address
    let address = CFSocketCopyAddress(socket)
    withUnsafeMutablePointer(&addr, {
      CFDataGetBytes(address, CFRange(location: CFIndex(0), length: CFIndex(addr.sin_len)), UnsafeMutablePointer($0))
    })

    // get the port from the sockaddr_in struct
    port = UInt16(bigEndian: addr.sin_port)
    print("The port is \(port).")
  }

  func receivedNewConnection(from: sockaddr_in, withNativeSocketHandle handle: CFSocketNativeHandle) {
    print("Got a new connection.")

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

    let client = Connection(ipAddress: address, port: port, input: readStream, output: writeStream)
    clients.append(client)
    client.sendMessage("Hello World\n")
  }

  override var library: Library! {
    return sourceLibrary
  }

  static func createNetServiceForName(name: String, port: UInt16) -> NSNetService {
    return NSNetService(domain: "", type: netServiceType, name: name, port: Int32(port))
  }

  func netServiceWillPublish(sender: NSNetService) {
    print("Will publish: \(sender)")
  }

  func netServiceDidPublish(sender: NSNetService) {
    print("Published NSNetService: \(sender)")
  }

  func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
    print("Could not publish: \(sender): \(errorDict)")
  }

}
