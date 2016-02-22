//
//  QueueItem.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/6/16.
//
//

import Foundation

class QueueItem: NSObject, CustomDebugStringConvertible {

  private static let idGenerator = UniqueGenerator()

  /** Stores a unique identifier for the item.  Used in network comms. */
  let identifier: UInt32

  /** Stores a reference to the underlying song.  Used to show information. */
  let song: Song

  let request: Request

  init(identifier: UInt32, song: Song) {
    self.identifier = identifier
    self.song = song
    self.request = Request()
    self.voted = .None
  }

  init(identifier: UInt32, song: Song, request: Request) {
    self.identifier = identifier
    self.song = song
    self.request = request
  }

  convenience init(song: Song) {
    self.init(identifier: QueueItem.idGenerator.next(), song: song)
  }

  /** Stores the internal number of votes.  Not publicly accessible. */
  private var votes: Int = 0

  /** Allows the rest of the application to access the vote count. */
  var currentRequestCount: Int {
    return votes
  }

  func upvote() {
    ++votes
  }

  func downvote() {
    --votes
  }

  override var debugDescription: String {
    return "QueueItem<name: \(song.name); votes: \(currentRequestCount)>"
  }
}
