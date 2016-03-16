//
//  Session.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class Session: NSObject {

  ///////////////
  // CONSTANTS //
  ///////////////

  // The constant type used to represent instances of our application.
  static let netServiceType = "_dj194._tcp"

  // The constants used for notifications for this Session.
  static let didChangeLibraryNotification = "Session.didChangeLibrary"
  static let didChangeQueueNotification = "Session.didChangeQueue"

  ////////////////
  // PROPERTIES //
  ////////////////

  /** This is the library that is loaded, or "nil" if there isn't one.

   Note that the Library might not be loaded, even if this is set. */
  var library: Library? {
    return nil
  }

  /** This is the Queue that is loaded, or "nil" if there isn't one.

   Note that the Queue might not be "loaded", even if there is an object. */
  var queue: Queue? {
    return nil
  }

  func sendDidChangeLibraryNotification() {
    sendDidChangeNotification(Session.didChangeLibraryNotification)
  }

  func sendDidChangeQueueNotification() {
    sendDidChangeNotification(Session.didChangeQueueNotification)
  }

  private func sendDidChangeNotification(name: String) {
    let center = NSNotificationCenter.defaultCenter()
    center.postNotificationName(name, object: self)
  }
}
