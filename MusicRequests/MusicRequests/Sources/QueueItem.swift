//
//  QueueItem.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/6/16.
//
//

import Foundation

class QueueItem: NSObject {

  /** Stores a unique identifier for the item.  Used in network comms. */
  let identifier: UInt32

  /** Stores a reference to the underlying song.  Used to show information. */
  let song: Song

  init(identifier: UInt32, song: Song) {
    self.identifier = identifier
    self.song = song
  }
}


class LocalQueueItem: QueueItem {

  /** Only LocalQueueItem objects should have IDs generated. */
  private static let idGenerator = UniqueGenerator()

  init(song: Song) {
    super.init(identifier: LocalQueueItem.idGenerator.next(), song: song)
  }

  /** The number of votes the song has acquired. */
  var votes = 0

  /** The vote count for sorting purposes.  Used to avoid weird behavior. */
  var votesForSorting: Int {
    return max(0, votes)
  }
}


class RemoteQueueItem: QueueItem {

  let request: Request

  init(identifier: UInt32, song: Song, request: Request) {
    self.request = request

    super.init(identifier: identifier, song: song)
  }
}
