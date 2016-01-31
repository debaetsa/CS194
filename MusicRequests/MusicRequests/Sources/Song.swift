//
//  Song.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//

import UIKit

class Song: Item {

  let album: Album?

  init(name: String, sortName: String, artist: Artist?, album: Album?, discNumber: Int?, trackNumber: Int?) {
    self.album = album

    super.init(name: name, sortName: sortName)

    self.album?.addSong(self, discNumber: discNumber, trackNumber: trackNumber)
  }

  convenience init(name: String, artist: Artist?, album: Album?, discNumber: Int?, trackNumber: Int?) {
    self.init(
      name: name,
      sortName: name,
      artist: artist,
      album: album,
      discNumber: discNumber,
      trackNumber: trackNumber
    )
  }

  var artists: NSSet {
    get {
      return NSSet()
    }
  }

  var genres: NSSet {
    get {
      return NSSet()
    }
  }

}
