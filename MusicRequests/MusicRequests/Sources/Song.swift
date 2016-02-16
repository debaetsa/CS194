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

  let artistOverride: Artist?
  var album: Album?
  let genre: Genre?

  init(name: String, sortName: String, artist: Artist?, album: Album?, genre: Genre?, discNumber: Int?, trackNumber: Int?, userInfo: AnyObject?) {

    self.userInfo = userInfo
    self.album = album
    self.genre = genre
    self.artistOverride = artist

    super.init(name: name, sortName: sortName)

    self.album?.addSong(self, discNumber: discNumber, trackNumber: trackNumber)
    self.genre?.addSong(self)
  }

  convenience init(name: String, artist: Artist?, album: Album?, discNumber: Int?, trackNumber: Int?) {
    self.init(
      name: name,
      sortName: name,
      artist: artist,
      album: album,
      genre: nil,
      discNumber: discNumber,
      trackNumber: trackNumber,
      userInfo: nil
    )
  }

  convenience init(name: String, artist: Artist?, album: Album?, genre: Genre?, discNumber: Int?, trackNumber: Int?, userInfo: AnyObject?) {
    self.init(
      name: name,
      sortName: name,
      artist: artist,
      album: album,
      genre: genre,
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
      genre: nil,
      discNumber: discNumber,
      trackNumber: trackNumber,
      userInfo: nil
    )
  }

  var artist: Artist? {
    return artistOverride ?? album?.artist
  }

  // MARK: - Sending

  override var tag: Tag {
    return .Song
  }

  override func buildSendableData(mutableData: NSMutableData) {
    // add the basic data
    super.buildSendableData(mutableData)

    // add the ID for the album
    mutableData.appendCustomInteger(self.album?.identifier ?? UInt32(0))

    // and then tell it which track we are on that album
    if let track = self.album?.trackForSong(self) {
      mutableData.appendCustomInteger(UInt32(track.disc ?? 0))
      mutableData.appendCustomInteger(UInt32(track.track ?? 0))
    } else {
      mutableData.appendCustomInteger(UInt32(0))
      mutableData.appendCustomInteger(UInt32(0))
    }
  }

  override init(data: NSData, lookup: [UInt32: Item]) {
    self.userInfo = nil
    self.artistOverride = nil
    self.genre = nil

    super.init(data: data, lookup: lookup)

    var offset = self.currentDataIndex
    let maybeAlbumId = data.getNextInteger(&offset)
    let maybeDiscNumber = data.getNextInteger(&offset)
    let maybeSongNumber = data.getNextInteger(&offset)
    self.currentDataIndex = offset

    if let albumId = maybeAlbumId, let item = lookup[albumId], let album = item as? Album {
      album.addSong(self, discNumber: Int(maybeDiscNumber ?? 0), trackNumber: Int(maybeSongNumber ?? 0))
      self.album = album
    } else {
      print("Could not find an album.")
    }
    // now try to add this song to the album
  }

}
