//
//  RemoteQueue.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/21/16.
//
//

import Foundation

class RemoteQueue: Queue {

  /** Store a reference to the associated Session.

   This is needed to allow sending the updated Request objects. */
  weak var remoteSession: RemoteSession!

  /** Stores requests that have been made but that have not yet appeared. */
  private var temporarySongRequests = [Song: Request]()

  private func loadCounts(data: NSData, inout offset: Int) -> (UInt8, UInt8, UInt8)? {
    var counts = [UInt8]()
    for _ in 0..<3 {
      guard let count = data.getNextByte(&offset) else {
        return nil
      }
      counts.append(count)
    }
    return (counts[0], counts[1], counts[2])
  }

  private func createQueueItem(forSong song: Song, withIdentifier identifier: UInt32) -> RemoteQueueItem {
    let request: Request

    if let boundRequest = temporarySongRequests.removeValueForKey(song) {
      request = boundRequest
    } else {
      request = Request()  // create a new one if we haven't requested it
    }

    let queueItem = RemoteQueueItem(identifier: identifier, song: song, request: request)
    request.queueItem = queueItem
    return queueItem
  }

  func updateFromData(data: NSData, usingLibrary library: RemoteLibrary) -> Bool {
    var offset = 0

    guard let counts = loadCounts(data, offset: &offset) else {
      return false
    }

    // then read all the objects
    var allQueueItems = [QueueItem]()
    for _ in 0..<(counts.0 + counts.1 + counts.2) {
      guard let queueItemIdentifier = data.getNextInteger(&offset) else {
        return false
      }
      guard let songIdentifier = data.getNextInteger(&offset) else {
        return false
      }

      if let queueItem = itemForIdentifier(queueItemIdentifier) {
        allQueueItems.append(queueItem)

      } else {
        if let item = library.itemForIdentifier(songIdentifier), let song = item as? Song {
          let queueItem = createQueueItem(forSong: song, withIdentifier: queueItemIdentifier)
          addQueueItem(queueItem)
          allQueueItems.append(queueItem)

        } else {
          return false  // couldn't load a QueueItem, so will ultimately fail
        }
      }
    }

    // finally, move them into the appropriate arrays
    changeAllItems(
      history: Array(allQueueItems.prefix(Int(counts.0))),
      current: (counts.1 > 0) ? allQueueItems[Int(counts.0)] : nil,
      upcoming: Array(allQueueItems.suffix(Int(counts.2)))
    )

    // Clear all the Song references, and then set the ones only for the
    // upcoming Songs.  This insures that the Library stays updated properly.
    for (_, item) in lookup {
      (item as! RemoteQueueItem).request.song = nil  // clear all the Songs
    }
    for item in upcoming {
      (item as! RemoteQueueItem).request.song = item.song  // and then re-add only the relevant
    }

    return true
  }

  /** Applies the specified Request, then forwards the Request.

   Now that we have the Request (either new or existing), we want to apply the
   vote to the Request and forward it to the server. */
  func applyVote(vote: Request.Vote, toRequest request: Request) {
    // apply the vote
    request.applyVote(vote)

    // and then send it to the server
    remoteSession.connection?.sendItem(request)
  }

  func changeVote(forSong song: Song, to vote: Request.Vote) {
    if let queueItem = findUpcomingItemForSong(song) {
      // We actually have an upcoming QueueItem for this Song, so just use that
      // for the logic.
      //
      // This handles the situation when the user votes for something already
      // in the Queue.  We will vote as if it had happened from the Queue.
      changeVote(forQueueItem: (queueItem as! RemoteQueueItem), to: vote)

    } else {
      // We don't have a QueueItem for this, so it is a new Request.  We'll
      // need to send just the Song to the server, remember it, and then mark
      // that QueueItem as requested when we get it back from the Server.
      let request: Request

      if let boundRequest = temporarySongRequests[song] {
        request = boundRequest

      } else {
        request = Request()
        request.song = song
        temporarySongRequests[song] = request
      }

      applyVote(vote, toRequest: request)
    }
  }

  func changeVote(forQueueItem queueItem: RemoteQueueItem, to vote: Request.Vote) {
    applyVote(vote, toRequest: queueItem.request)
  }

  func upvote(withSong song: Song) {
    changeVote(forSong: song, to: .Up)
  }

  func upvote(withQueueItem queueItem: RemoteQueueItem) {
    changeVote(forQueueItem: queueItem, to: .Up)
  }

  func downvote(withSong song: Song) {
    changeVote(forSong: song, to: .Down)
  }

  func downvote(withQueueItem queueItem: RemoteQueueItem) {
    changeVote(forQueueItem: queueItem, to: .Down)
  }
}
