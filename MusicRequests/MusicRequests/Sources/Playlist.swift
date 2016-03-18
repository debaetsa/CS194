//
//  Playlist.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//

import UIKit

class Playlist: Item {

  override init(name: String, sortName: String) {
    super.init(name: name, sortName: sortName)
  }

  // A Playlist is a list of songs, and it is empty by default.
  private var songs: [Song] = []
  var allSongs: [Song] {
    return songs
  }

  func addSong(song: Song) {
    songs.append(song)
  }

  // MARK: - Sending

  override var tag: Tag {
    return .Playlist
  }

  override func buildSendableData(mutableData: NSMutableData) {
    super.buildSendableData(mutableData)

    // note the identifiers of all of the Songs in this Playlist
    for song in allSongs {
      mutableData.appendCustomInteger(song.identifier)
    }
  }

  required init?(data: NSData, lookup: [UInt32: Item], inout offset: Int) {
    super.init(data: data, lookup: lookup, offset: &offset)

    // iterate through each Song in the Playlist to add them
    while let identifier = data.getNextInteger(&offset) {
      if let item = lookup[identifier], let song = item as? Song {
        addSong(song)
      }
    }
  }

}

