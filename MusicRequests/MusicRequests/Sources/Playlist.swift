//
//  Playlist.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//

import UIKit

class Playlist: Item {

  // A Playlist is a list of songs, and it is empty by default.
  private var songs: [Song] = []
  var allSongs: [Song] {
    return songs
  }

  func addSong(song: Song) {
    songs.append(song)
  }

}

