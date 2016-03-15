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
  
  //This crashes on my phone because I have less than 15 songs so I've fixed 
  //this by making it the minimum of this or the total number of songs on the
  //phone
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

  /** Changes the QueueItem objects in this queue to the specified Arrays. */
  func changeAllItems(history history: [QueueItem], current: QueueItem?, upcoming: [QueueItem]) {
    // finally, move them into the appropriate arrays
    previousQueueItems = history
    currentQueueItem = current
    upcomingQueueItems = upcoming

    let center = NSNotificationCenter.defaultCenter()
    center.postNotificationName(Queue.didChangeNowPlayingNotification, object: self)
  }


  init(nowPlaying: NowPlaying, sourceLibrary: Library) {
    self.nowPlaying = nowPlaying
    self.library = sourceLibrary

    super.init()

    self.nowPlaying.queue = self
  }

  convenience init(library: Library) {
    self.init(nowPlaying: NowPlaying(), sourceLibrary: library)
  }

  func addQueueItem(item: QueueItem) {
    // TODO: Make sure that we don't already have a QueueItem.
    lookup[item.identifier] = item
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
}

class LocalQueue: Queue {

  override init(nowPlaying: NowPlaying, sourceLibrary: Library) {
    super.init(nowPlaying: nowPlaying, sourceLibrary: sourceLibrary)

    fillToMinimum()  // put in the original songs -- only for Local queues
  }

  convenience init(library: Library) {
    self.init(nowPlaying: LocalNowPlaying(), sourceLibrary: library)
  }

  private func createQueueItem(forSong song: Song) -> LocalQueueItem {
    let queueItem = LocalQueueItem(song: song)
    addQueueItem(queueItem)
    return queueItem
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
      shouldForceUpdate = true
      return item
    }
  }

  // MARK: - Queue Filling and Sorting

  /** Fills to the upcoming queue to the minimum required length.

   This will only do something if the current queue length is less than the
   minimum requirement.  If there are already enough songs (even if none of
   them were randomly generated), then it will have no impact. */
  private func fillToMinimum() -> Void {
    let count = upcomingQueueItems.count
    let target = Queue.minimumUpcomingCount

    for _ in count..<target {
      let maybeSong = library.pickRandomSong()
      guard let song = maybeSong else {
        // If we didn't get a result back, we have to stop adding songs.
        return
      }

      upcomingQueueItems.append(createQueueItem(forSong: song))
      shouldForceUpdate = true
    }
  }

  /** Tracks whether or not a "forced update" change has been made. */
  private var shouldForceUpdate: Bool = false

  /** Sorts the list of upcoming QueueItem objects. */
  func sort() -> Bool {
    upcomingQueueItems.sortInPlace {
      let one = $0 as! LocalQueueItem
      let two = $1 as! LocalQueueItem
      
      var one_pos = -1
      for (var i = previousQueueItems.count-1; i >= 0; i--) {
        if (previousQueueItems[i].song.name == one.song.name){
          one_pos = previousQueueItems.count-i
          break
        }
      }
      
      var two_pos = -1
      for (var i = previousQueueItems.count-1; i >= 0; i--) {
        if (previousQueueItems[i].song.name == two.song.name){
          two_pos = previousQueueItems.count-i
          break
        }
      }
      
      let etv_one = (one_pos == -1) ? Double(one.votes) : (log(Double(one_pos+1))/log(Double(previousQueueItems.count+1))) * Double(one.votes)
      
      let etv_two = (two_pos == -1) ? Double(two.votes) : (log(Double(two_pos+1))/log(Double(previousQueueItems.count+1))) * Double(two.votes)

      return (etv_one == etv_two) ? one.identifier < two.identifier : etv_one > etv_two
    }
    return true
  }

  /** Refreshes the Queue, resorting it, and potentially notifying.

   This should be called after any changes are made to the Queue in order to
   normalize everything.  It will send out a notification as needed. */
  func refresh() {
    // set this based on whether or not anything changes in the Queue
    let didChange = sort()

    if didChange || shouldForceUpdate {
      let center = NSNotificationCenter.defaultCenter()
      center.postNotificationName(Queue.didChangeNowPlayingNotification, object: self)
    }
    shouldForceUpdate = false
  }


  // MARK: - Playing

  /** Advances to the next Song.

   This involves adding the current song to the list of previously-played songs,
   updating the currently playing song, and then grabbing a new Song. */
  func advanceToNextSong() {
    guard let nextSong = upcomingQueueItems.first else {
      return  // don't change anything if we can't switch to the next Song
    }

    // If there was something playing, move it to the history list.
    if let previousSong = currentQueueItem {
      previousQueueItems.append(previousSong)
    }

    // We then want to update the currentQueueItem to be the one that we are
    // taking from the queue of upcoming songs.
    currentQueueItem = nextSong
    upcomingQueueItems.removeAtIndex(0)

    shouldForceUpdate = true
    refresh()
  }

  /** Returns to the Song that was most recently played.

   This involves adding the current song to the list of upcoming songs,
   updating the currently playing song, and then grabbing a new Song. */
  func returnToPreviousSong() {
    guard let previousSong = previousQueueItems.last else {
      return  // do nothing if there isn't a previous Song
    }

    // If there was something playing, move it to the upcoming list.
    if let nextSong = currentQueueItem {
      upcomingQueueItems.insert(nextSong, atIndex: 0)
    }

    // Then update the current song with the one we retrieved from the list of
    // previous QueueItem objects.
    currentQueueItem = previousSong
    previousQueueItems.removeLast()

    // And then refresh() with a forced update since we changed the contents of
    // the lists.
    shouldForceUpdate = true
    refresh()
  }

}
