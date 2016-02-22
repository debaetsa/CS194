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

  var lookup = [UInt32: QueueItem]()


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

  func createQueueItem(forSong song: Song, withIdentifier maybeIdentifier: UInt32? = nil) -> QueueItem {
    let item: QueueItem
    if let identifier = maybeIdentifier {
      item = QueueItem(identifier: identifier, song: song)
    } else {
      item = QueueItem(song: song)
    }
    lookup[item.identifier] = item
    return item
  }

  /** Finds the item for the specified Song, creating it if needed.

   This will find an upcoming item for the specified Song.  If there is already
   an upcoming item for the Song, it will return that.  If not, it will create
   it and add it to the list of upcoming songs. */
  func createUpcomingItemForSong(song: Song) -> QueueItem {
    if let queueItem = findUpcomingItemForSong(song) {
      return queueItem
    } else {
      // We weren't able to find a QueueItem for the song, so create one.
      let item = createQueueItem(forSong: song)
      upcomingQueueItems.append(item)
      return item
    }
  }

  /** Finds the upcoming QueueItem for the Song.

   Note that this DOES NOT create a new QueueItem if one doesn't exist. */
  func findUpcomingItemForSong(song: Song) -> QueueItem? {
    // First try to search for the Song.
    for item in upcoming {
      if item.song == song {
        return item
      }
    }
    return nil
  }

  func itemForIdentifier(identifier: UInt32) -> QueueItem? {
    return lookup[identifier]
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
      upcomingQueueItems.append(createQueueItem(forSong: song))
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

    var items = previousQueueItems
    if let current = currentQueueItem {
      items.append(current)
    }
    items.appendContentsOf(upcomingQueueItems)

    for item in items {
      data.appendCustomInteger(item.identifier)
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

    // then read all the objects
    var allQueueItems = [QueueItem]()
    for _ in 0..<(historyCount + currentCount + upcomingCount) {
      guard let queueItemIdentifier = data.getNextInteger(&offset) else {
        return false
      }
      guard let songIdentifier = data.getNextInteger(&offset) else {
        return false
      }
      if let item = library.itemForIdentifier(songIdentifier), let song = item as? Song {
        if let queueItem = itemForIdentifier(queueItemIdentifier) {
          assert(queueItem.song === song)  // QueueItems should always be the same Song
          allQueueItems.append(queueItem)  // re-using the item
        } else {
          allQueueItems.append(
            createQueueItem(forSong: song, withIdentifier: queueItemIdentifier)
          )
        }

      } else {
        print("Couldn't get a Song for ID \(songIdentifier).")
      }
    }

    // finally, move them into the appropriate arrays
    previousQueueItems.appendContentsOf(allQueueItems.prefix(Int(historyCount)))
    if currentCount > 0 {
      currentQueueItem = allQueueItems[Int(historyCount)]
    }
    upcomingQueueItems.appendContentsOf(allQueueItems.suffix(Int(upcomingCount)))

    let center = NSNotificationCenter.defaultCenter()
    center.postNotificationName(Queue.didChangeNowPlayingNotification, object: self)

    return true
  }
}
