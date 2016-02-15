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


  ////////////////
  // PROPERTIES //
  ////////////////

  /** This is the Queue for the session.

   Because each type of session will require a different Queue (we only use the
   current device's Apple library when playing locally), we need to associate
   the Queue with each session as well. */
  let queue: Queue

  /** This is the Library that should be shown to the user.

   It is generally the filtered library for the broadcasting device, and it is
   the received library (the only one) for the listening device. */
  var library: Library! {
    // This is not meant to be invoked.  By making it an implicitly-unwrapped
    // optional and returning nil, we'll ensure that it crashes if this code is
    // ever executed.
    return nil
  }

  init(queue: Queue) {
    self.queue = queue

    super.init()
  }

}
