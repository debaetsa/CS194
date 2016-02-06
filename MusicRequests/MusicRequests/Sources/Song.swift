//
//  Song.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//

import UIKit

class Song: Item {

  /** Can be used to associate arbitrary data with a Song.

  This is helpful to store some identifier to allow us to actually play a song.
  It uses a generic type so that this class can be reused for multiple data
  sources. */
  let userInfo: AnyObject?

  let album: Album?

  init(name: String, sortName: String, artist: Artist?, album: Album?, discNumber: Int?, trackNumber: Int?, userInfo: AnyObject?) {

    self.userInfo = userInfo
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
      trackNumber: trackNumber,
      userInfo: nil
    )
  }

  convenience init(name: String, artist: Artist?, album: Album?, discNumber: Int?, trackNumber: Int?, userInfo: AnyObject?) {
    self.init(
      name: name,
      sortName: name,
      artist: artist,
      album: album,
      discNumber: discNumber,
      trackNumber: trackNumber,
      userInfo: userInfo
    )
  }

  convenience init(name: String, sortName: String, artist: Artist?, album: Album?, discNumber: Int?, trackNumber: Int?) {
    self.init(
      name: name,
      sortName: sortName,
      artist: artist,
      album: album,
      discNumber: discNumber,
      trackNumber: trackNumber,
      userInfo: nil
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
