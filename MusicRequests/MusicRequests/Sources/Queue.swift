//
//  Queue.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class Queue: NSObject {

  /** Stores the minimum size for the upcoming queue. */
  private static let minimumUpcomingCount = 15;

  /** Stores the times when songs were most recently played. */
  private var lastPlayed = [Song: NSDate]()

  /** Stores the Library reference for randomly chosen songs. */
  private let library: Library

  /** Stores the NowPlaying reference, which is available publicly. */
  let nowPlaying: NowPlaying

  init(nowPlaying: NowPlaying, sourceLibrary: Library) {
    self.nowPlaying = nowPlaying
    self.library = sourceLibrary

    super.init()

    // After initializing "self", we can set the generator for NowPlaying.
    self.nowPlaying.generator = { [unowned self] in
      if let nextSong = self.upcomingQueueItems.first {
        self.upcomingQueueItems.removeAtIndex(0)
        return nextSong
      }

      // We couldn't find anything, so say that there isn't a song.
      return nil
    }

    self.fillToMinimum()
  }

  convenience init(library: Library) {
    self.init(nowPlaying: NowPlaying(), sourceLibrary: library)
  }

  /** Finds the item for the specified Song, creating it if needed.

  This will find an upcoming item for the specified Song.  If there is already
  an upcoming item for the Song, it will return that.  If not, it will create
  it and add it to the list of upcoming songs. */
  func itemForSong(song: Song) -> QueueItem {
    // First try to search for the Song.
    for item in upcoming {
      if item.song == song {
        return item
      }
    }

    // We weren't able to find a QueueItem for the song, so create one.
    let item = QueueItem(song: song)
    upcomingQueueItems.append(item)
    return item
  }

  /** Fills to the upcoming queue to the minimum required length.

  This will only do something if the current queue length is less than the
  minimum requirement.  If there are already enough songs (even if none of them
  were randomly generated, then it will have no impact. */
  private func fillToMinimum() -> Void {
    let count = upcomingQueueItems.count
    for _ in count ..< Queue.minimumUpcomingCount {
      let maybeSong = library.pickRandomSong()

      guard let song = maybeSong else {
        // If we didn't get a result back, we have to stop adding songs.
        return
      }

      // TODO: Fix this issue.
      // Using this approach will technically allow multiple copies of a song
      // to appear in the Queue.  We can address that later.
      upcomingQueueItems.append(QueueItem(song: song))
    }
  }

  private var upcomingQueueItems = [QueueItem]()
  var upcoming: [QueueItem] {
    return upcomingQueueItems
  }

  var history: [QueueItem] {
    return []
  }

}
