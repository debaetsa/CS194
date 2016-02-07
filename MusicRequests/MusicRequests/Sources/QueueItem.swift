//
//  QueueItem.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/6/16.
//
//

import Foundation

class QueueItem: NSObject, CustomDebugStringConvertible {

  private static var uniqueIdentifier = 0
  private static func generateUniqueIdentifier() -> Int {
    ++uniqueIdentifier
    return uniqueIdentifier
  }

  /** Stores a unique identifier for the item.  Used in network comms. */
  private let id: Int

  /** Stores the internal number of votes.  Not publicly accessible. */
  private var votes: Int = 0

  /** Stores a reference to the underlying song.  Used to show information. */
  let song: Song

  init(song: Song) {
    self.id = QueueItem.generateUniqueIdentifier()
    self.song = song
  }

  /** Allows the rest of the application to access the vote count. */
  var currentRequestCount: Int {
    return votes
  }

  override var debugDescription: String {
    return "QueueItem<name: \(song.name); votes: \(currentRequestCount)>"
  }

}
