//
//  Genre.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//

import UIKit

class Genre: Item {

  var songs = [Song]()
  var allSongs: [Song] {
    return songs
  }

  func addSong(song: Song) {
    songs.append(song)
  }

  override func didFinishImporting() {
    songs.sortInPlace(Item.sorter)
  }

  // MARK: - Sending

  override var tag: Tag {
    return .Genre
  }

}
