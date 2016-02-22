//
//  SongRequest.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/21/16.
//
//

import Foundation

class Request: NSObject, Sendable {

  enum Vote: UInt8 {
    case None = 0
    case Up
    case Down
  }

  /** The reference to the Song of this Request.

   If this is set, then it means that this is still an upcoming Request, and it
   means that we should show the Song as highlighted in the Library.  Once the
   Song is played (i.e., not in the list of upcoming), this will be cleared,
   and when it is, we'll also clear the Request status of the Song. */
  var song: Song? {
    didSet {
      if let song = self.song {
        // We just set a new Song for this Request, so send the Vote.
        song.cachedVote = vote

      } else {
        if let song = oldValue {
          song.cachedVote = .None  // clear any Vote
        }
      }
    }
  }

  /** Stores the QueueItem for the Song.

   If this is set, then we'll always use its identifier when sending the
   Request.  If it is not set, then we'll use the Song identifier. */
  weak var queueItem: QueueItem?

  /** Stores the Vote status of this Request.

   When we call "upvote" or "downvote", we'll use this to determine exactly
   what we need to send and how we need to respond. */
  var vote = Vote.None {
    didSet {
      if let song = self.song {
        song.cachedVote = vote  // we changed the Vote, so show in the library
      }
    }
  }

  /** Applies a vote of the specified type.

   The behavior is as follows:

     - "None" will always set it back to "None."

     - "Up" will undo an "Up"; else set it to "Up".

     - "Down" is the reverse of "Up". */
  func applyVote(vote: Vote) {
    let appliedVote: Vote

    if vote == .None {
      appliedVote = vote
    } else {
      if self.vote == vote {
        appliedVote = .None
      } else {
        appliedVote = vote
      }
    }

    self.vote = appliedVote
  }

  override init() {
  }

  // MARK: - Sending

  enum Tag: UInt8 {
    case Song = 1
    case QueueItem
  }

  var sendableIdentifier: SendableIdentifier {
    return .Request
  }

  var sendableData: NSData {
    // these are what will be sent for the Request
    let tag: Tag
    let identifier: UInt32

    // so figure out exactly what we're sending
    if let boundQueueItem = queueItem {
      tag = .QueueItem
      identifier = boundQueueItem.identifier

    } else {
      // In this case, we MUST have a Song or the object is in an inconsistent
      // state.  If that's the case, we want to crash and fix it.
      let boundSong = song!

      tag = .Song
      identifier = boundSong.identifier
    }

    // build the data object that will be sent
    let data = NSMutableData()
    data.appendByte(tag.rawValue)
    data.appendByte(vote.rawValue)
    data.appendCustomInteger(identifier)
    return data
  }

  init?(data: NSData, lookup: [UInt32: Item], queue: Queue) {
    super.init()  // nothing to configure before super

    var offset = 0

    // read the value and parse it as a valid Request.Tag
    guard let tagRawValue = data.getNextByte(&offset), let tag = Tag(rawValue: tagRawValue) else {
      return nil
    }

    // read the value parse it as a valid Vote (Up/Down/None)
    guard let voteRawValue = data.getNextByte(&offset), let vote = Vote(rawValue: voteRawValue) else {
      return nil
    }
    self.vote = vote

    // finally, get the identifier that we'll use to find the object
    guard let identifier = data.getNextInteger(&offset) else {
      return nil
    }


    switch tag {
    case .QueueItem:
      if let queueItem = queue.itemForIdentifier(identifier) {
        self.queueItem = queueItem  // mark the appropriate QueueItem
      } else {
        return  nil
      }

    case .Song:
      if let item = lookup[identifier], let song = item as? MusicRequests.Song {
        self.song = song  // this just has a Song, so only set that value
      } else {
        return nil
      }
    }
  }
}
