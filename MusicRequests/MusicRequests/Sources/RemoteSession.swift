//
//  RemoteSession.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class RemoteSession: Session {

  /** Stores the netService, meant to be used only by the manager. */
  let netService: NSNetService

  /** Stores the name of the session, as set by the remote user. */
  let name: String

  init(netService: NSNetService) {
    self.netService = netService
    self.name = netService.name

    // TODO: Create a Queue() specifically for this remote session.  Just know
    // that it will probably not be populated until it is actually accessed.
    super.init(queue: Queue(library: TemporaryLibrary()))
  }

}
