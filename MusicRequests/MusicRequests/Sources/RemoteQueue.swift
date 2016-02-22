//
//  RemoteQueue.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/21/16.
//
//

import Foundation

class RemoteQueue: Queue {
  /** Stores requests that have been made but that have not yet appeared. */
  private var pendingRequests = [Song: Request]()

  override func updateFromData(data: NSData, usingLibrary library: RemoteLibrary) -> Bool {
    super.updateFromData(data, usingLibrary: library)

    // At this point, figure out if we have any matching requests for anything
    // that is coming up in the Queue.

    // And after that, update all of the relevant Song objects to point to the
    // cached Request objects.
  }
}
