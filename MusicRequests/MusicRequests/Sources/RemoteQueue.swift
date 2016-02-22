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

  override func createQueueItem(forSong song: Song, withIdentifier maybeIdentifier: UInt32?) -> QueueItem {
    let identifier = maybeIdentifier!  // we also specify an Identifier

    let request: Request
    if let boundRequest = temporarySongRequests[song] {
      request = boundRequest
      temporarySongRequests.removeValueForKey(song)
    } else {
      request = Request()  // haven't requested, so create an empty object
    }

    let item = QueueItem(identifier: identifier, song: song, request: request)
    request.queueItem = item
    lookup[item.identifier] = item
    return item
  }

  override func updateFromData(data: NSData, usingLibrary library: RemoteLibrary) -> Bool {
    let result = super.updateFromData(data, usingLibrary: library)

    // At this point, figure out if we have any matching requests for anything
    // that is coming up in the Queue.

    // And after that, update all of the relevant Song objects to point to the
    // cached Request objects.

    for (_, item) in lookup {
      item.request.song = nil  // clear all the Songs
    }
    for item in upcoming {
      item.request.song = item.song  // and then re-add only the relevant
    }

    return result
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
      changeVote(forQueueItem: queueItem, to: vote)

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

  func changeVote(forQueueItem queueItem: QueueItem, to vote: Request.Vote) {
    applyVote(vote, toRequest: queueItem.request)
  }

  func upvote(withSong song: Song) {
    changeVote(forSong: song, to: .Up)
  }

  func upvote(withQueueItem queueItem: QueueItem) {
    changeVote(forQueueItem: queueItem, to: .Up)
  }

  func downvote(withSong song: Song) {
    changeVote(forSong: song, to: .Down)
  }

  func downvote(withQueueItem queueItem: QueueItem) {
    changeVote(forQueueItem: queueItem, to: .Down)
  }
}
