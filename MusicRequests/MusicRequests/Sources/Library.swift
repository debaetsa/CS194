//
//  Library.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class Library: NSObject {

  var allSongs: [Song] { return [] }
  
  var allArtists: [Artist] { return [] }
  
  var allAlbums: [Album] { return [] }

  var allPlaylists: [Playlist] { return [] }

  var allGenres: [Genre] { return [] }

  func pickRandomSong() -> Song? {
    let songs = allSongs
    let count = songs.count

    guard count > 0 else {
      // Ensure that there is at least some song to return.
      return nil
    }

    return songs[Int(arc4random_uniform(UInt32(count)))]
  }

  let globallyUniqueIdentifier: NSUUID

  init(globallyUniqueIdentifier: NSUUID? = nil) {
    self.globallyUniqueIdentifier = globallyUniqueIdentifier ?? NSUUID()
  }

  var isLoaded: Bool {
    return doneLoading
  }

  private var onLoadBlocks: [() -> ()] = []
  private var doneLoading = false {
    didSet {
      if doneLoading {
        for block in onLoadBlocks {
          block()
        }
        onLoadBlocks.removeAll()
      }
    }
  }

  func finishLoading() {
    doneLoading = true
  }

  /** Runs the provided block when the Library is loaded.

   If the Library is already loaded, then it is run immediately.  Otherwise, it
   is queued until "finishLoading()" is called. */
  func runWhenLoaded(block: () -> ()) {
    if isLoaded {
      block()  // run it now
    } else {
      onLoadBlocks.append(block)  // run it later
    }
  }

}
