//
//  Library.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

protocol Library {

  var allSongs: [Song] { get }
  
  var allArtists: [Artist] { get }
  
  var allAlbums: [Album] { get }

  var allPlaylists: [Playlist] { get }

  var allGenres: [Genre] { get }

  func pickRandomSong() -> Song?

}

/** Define an extension to the protocol.

This code is automatically usable by all classes implementing the Library
protocol.  Since it only depends on methods in the protocol, it can be entirely
implemented here. */
extension Library {
  func pickRandomSong() -> Song? {
    let songs = allSongs
    let count = songs.count

    guard count > 0 else {
      // Ensure that there is at least some song to return.
      return nil
    }

    let index = Int(arc4random_uniform(UInt32(count)))
    return songs[index]
  }
}
