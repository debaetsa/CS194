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
  private let identifier: UInt32

  /** Stores the internal number of votes.  Not publicly accessible. */
  private var votes: Int = 0

  /** Stores a reference to the underlying song.  Used to show information. */
  let song: Song

  init(song: Song) {
    self.identifier = QueueItem.idGenerator.next()
    self.song = song
  }

  /** Allows the rest of the application to access the vote count. */
  var currentRequestCount: Int {
    return votes
  }

  override var debugDescription: String {
    return "QueueItem<name: \(song.name); votes: \(currentRequestCount)>"
  }

  enum Voted {
    case None
    case Up
    case Down
  }

  private var voted: Voted = .Up
  var isUpvoted: Bool {
    return voted == .Up
  }
  var isDownvoted: Bool {
    return voted == .Down
  }

  /** Upvotes the current QueueItem.

   This will clear the vote if it is called when it's already upvoted. */
  func upvote() {
    switch voted {
    case .Up:
      voted = .None

    case .Down: fallthrough
    case .None:
      voted = .Up
    }
  }

  /** Downvotes the current QueueItem.

   This will clear the vote if it is called when it's already upvoted. */
  func downvote() {
    switch voted {
    case .Down:
      voted = .None

    case .Up: fallthrough
    case .None:
      voted = .Down
    }
  }

}
