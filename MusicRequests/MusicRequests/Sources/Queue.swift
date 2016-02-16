//
//  Queue.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class Queue: NSObject {

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
    let maybeSongs = library.rankSongsByVotes(0)
    var counter = 0
    for _ in count ..< Queue.minimumUpcomingCount {
//      let maybeSong = library.pickRandomSong()
      let song = maybeSongs[counter]
      if (counter >= library.allSongs.count) {
        return
      }
      counter++;
//      guard let song = maybeSong else {
//        // If we didn't get a result back, we have to stop adding songs.
//        return
//      }

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
    if nextSong != nil {
      upcomingQueueItems.removeAtIndex(0)
    }

    // Post a notification informing the rest of application about the change.
    let center = NSNotificationCenter.defaultCenter()
    center.postNotificationName(Queue.didChangeNowPlayingNotification, object: self)
  }
  
  /** Returns to the previous played song.
  
  */
  func returnToPreviousSong() {
    //if there was something playing, move it to the upcoming list.
    if let nextSong = currentQueueItem {
      upcomingQueueItems.insert(nextSong, atIndex: 0)
    }
    
    //place the previous song in the current position.
    currentQueueItem = previousQueueItems.removeLast()
   
    // Post a notification informing the rest of application about the change.
    let center = NSNotificationCenter.defaultCenter()
    center.postNotificationName(Queue.didChangeNowPlayingNotification, object: self)
  }
  
  /** Refreshes the queue to take into account new votes.

   * A couple things I don't like about this: 
   * (1) Right now, I have to keep a parallel set of queuedSongs to avoid an ugly
   * O(n^2) iteration over upcomingQueueItems to prevent duplication of songs. I
   * think we can get rid of the QueueItem class entirely if you're okay with it.
   * 
   * (2) This keeps the queue at minimum upcoming count for now--we should talk 
   * through exactly what we want the queue to do later.
   */
  func refreshUpcoming() {

    var queuedSongs = Set<Song>()
    for item in upcomingQueueItems {
      queuedSongs.insert(item.song)
    }
    let minVotes = upcomingQueueItems[upcomingQueueItems.count - 1].song.votes!
    let toAddSongs = library.rankSongsByVotes(minVotes)

    for song in toAddSongs {
      if !queuedSongs.contains(song) {
        upcomingQueueItems.append(QueueItem(song: song))
        queuedSongs.insert(song)
      }
    }
    upcomingQueueItems = upcomingQueueItems.sort({ (first, second) -> Bool in
      if (first.song.votes! > second.song.votes!) {
        return true;
      } else {
        return false;
      }
    })
    upcomingQueueItems = Array(upcomingQueueItems[0..<Queue.minimumUpcomingCount])
  }
}
