//
//  Queue.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class Queue: NSObject, Sendable {

  //////////////////////
  // PUBLIC CONSTANTS //
  //////////////////////

  /** The identifier for the Notification sent when NowPlaying changes. */
  static let didChangeNowPlayingNotification = "Queue.didChangeNowPlaying"


  //////////////////////
  // PUBLIC VARIABLES //
  //////////////////////

  /** Stores the NowPlaying reference, which is available publicly. */
  let nowPlaying: NowPlaying

  /** Stores the list of QueueItems that are about to be played.

  Items are removed as they start playing. */
  var upcoming: [QueueItem] {
    return upcomingQueueItems
  }

  /** Stores the list of QueueItems that have been played already.

  Items are never removed from this list, though it probably makes sense to not
  show them all in the UI.  Basically something along the lines of:

    previousItemsToShow = MIN(15, history.count)

  which will show at most 15 items from the history. */
  var history: [QueueItem] {
    return previousQueueItems
  }

  var current: QueueItem? {
    return currentQueueItem
  }


  ///////////////////////
  // PRIVATE CONSTANTS //
  ///////////////////////

  /** Stores the minimum size for the upcoming queue. */
  private static let minimumUpcomingCount = 15;


  ///////////////////////
  // PRIVATE VARIABLES //
  ///////////////////////

  /** Stores the times when songs were most recently played. */
  private var lastPlayed = [Song: NSDate]()

  /** Stores the Library reference for randomly chosen songs. */
  private let library: Library

  /** These three variables store the queue.

  Concatenating previousQueueItems + [currentQueueItem] + upcomingQueueItems
  gives the playlist order of the songs.  This means that we pull songs from
  the front of upcomingQueueItems, and we add previously played items to the
  back of previousQueueItems.
   
  It is possible for currentQueueItem to be nil if we are not playing anything,
  but it should always be set when the app is in progress. */
  private var upcomingQueueItems = [QueueItem]()
  private var currentQueueItem: QueueItem?
  private var previousQueueItems = [QueueItem]()


  init(nowPlaying: NowPlaying, sourceLibrary: Library) {
    self.nowPlaying = nowPlaying
    self.library = sourceLibrary

    super.init()

    self.nowPlaying.queue = self
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

  /** Advances to the next Song.

   This involves adding the current song to the list of previously-played songs,
   updating the currently playing song, and then grabbing a new Song. */
  func advanceToNextSong() {
    // If there was something playing, move it to the history list.
    if let previousSong = currentQueueItem {
      previousQueueItems.append(previousSong)
    }

    // Otherwise, pick the next song to play, if there is one.  (Note that we
    // should always have one to play since we pick random songs.)
    let nextSong = upcomingQueueItems.first
    currentQueueItem = nextSong
    if let _ = nextSong {
      upcomingQueueItems.removeAtIndex(0)
    }

    // Post a notification informing the rest of application about the change.
    let center = NSNotificationCenter.defaultCenter()
    center.postNotificationName(Queue.didChangeNowPlayingNotification, object: self)
  }

  /** Returns to the Song that was most recently played.

   This involves adding the current song to the list of upcoming songs,
   updating the currently playing song, and then grabbing a new Song. */
  func returnToPreviousSong() {
    // If there was something playing, move it to the upcoming list.
    if let nextSong = currentQueueItem {
      upcomingQueueItems.insert(nextSong, atIndex: 0)
    }

    // Place the most recent song in the "now playing" position.
    let previousSong = previousQueueItems.last
    currentQueueItem = previousSong
    if let _ = previousSong {
      previousQueueItems.removeLast()
    }

    // Post a notification informing the rest of application about the change.
    let center = NSNotificationCenter.defaultCenter()
    center.postNotificationName(Queue.didChangeNowPlayingNotification, object: self)
  }

  // MARK: - Sending

  // DATA FORMAT
  //
  // +----------------+
  // | HISTORY COUNT  |
  // +----------------+
  // | CURRENT COUNT  |  (probably 1 or 0)
  // +----------------+
  // | UPCOMING COUNT |
  // +----------------+
  // | HIST/CUR/UPCOM |
  // +----------------+

  var sendableIdentifier: SendableIdentifier {
    return .Queue
  }

  var sendableData: NSData {
    let data = NSMutableData()

    data.appendByte(UInt8(previousQueueItems.count))
    data.appendByte(UInt8(currentQueueItem != nil ? 1 : 0))
    data.appendByte(UInt8(upcomingQueueItems.count))

    for item in previousQueueItems {
      data.appendCustomInteger(item.song.identifier)
    }
    if let item = currentQueueItem {
      data.appendCustomInteger(item.song.identifier)
    }
    for item in upcomingQueueItems {
      data.appendCustomInteger(item.song.identifier)
    }

    return data
  }

  func updateFromData(data: NSData, usingLibrary library: RemoteLibrary) -> Bool {
    var offset = 0
    guard let historyCount = data.getNextByte(&offset) else {
      return false
    }
    guard let currentCount = data.getNextByte(&offset) else {
      return false
    }
    guard let upcomingCount = data.getNextByte(&offset) else {
      return false
    }

    // clear out the existing data before we replace it
    previousQueueItems.removeAll()
    currentQueueItem = nil
    upcomingQueueItems.removeAll()

    // then add all the objects
    for _ in 0..<historyCount {
      guard let identifier = data.getNextInteger(&offset) else {
        return false
      }
      if let item = library.itemForIdentifier(identifier), let song = item as? Song {
        previousQueueItems.append(QueueItem(song: song))
      } else {
        print("Couldn't get a Song for ID \(identifier).")
      }
    }

    if currentCount > 0 {
      guard let identifier = data.getNextInteger(&offset) else {
        return false
      }
      if let item = library.itemForIdentifier(identifier), let song = item as? Song {
        upcomingQueueItems.append(QueueItem(song: song))
      } else {
        print("Couldn't get a Song for ID \(identifier).")
      }
    }

    for _ in 0..<upcomingCount {
      guard let identifier = data.getNextInteger(&offset) else {
        return false
      }
      if let item = library.itemForIdentifier(identifier), let song = item as? Song {
        upcomingQueueItems.append(QueueItem(song: song))
      } else {
        print("Couldn't get a Song for ID \(identifier).")
      }
    }

    let center = NSNotificationCenter.defaultCenter()
    center.postNotificationName(Queue.didChangeNowPlayingNotification, object: self)

    return true
  }
}
