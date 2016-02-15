//
//  LocalSession.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class LocalSession: Session {

  /** Whether or not the session should be broadcast on the network.

   If "false", then the app can be used in a "local playback only" mode. */
  var broadcast: Bool = false

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

  init(library: Library, queue: Queue) {
    self.fullLibrary = library
    self.sourceLibrary = library
    self.netService = LocalSession.createNetServiceForName("")

    super.init(queue: queue)
  }

  override var library: Library! {
    return sourceLibrary
  }

  static func createNetServiceForName(name: String) -> NSNetService {
    return NSNetService(domain: "", type: netServiceType, name: name, port: 8000)
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
