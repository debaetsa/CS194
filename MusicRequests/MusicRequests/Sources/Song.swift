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
  var cachedVoteStatus = Request.Voted.None

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
    let track = self.album?.trackForSong(self)
    mutableData.appendCustomInteger(UInt32(track?.disc ?? 0))
    mutableData.appendCustomInteger(UInt32(track?.track ?? 0))
  }

  required init?(data: NSData, lookup: [UInt32: Item], inout offset: Int) {
    self.userInfo = nil
    self.artistOverride = nil
    self.genre = nil

    super.init(data: data, lookup: lookup, offset: &offset)

    guard let albumId = data.getNextInteger(&offset) else {
      return nil
    }
    guard let discNumber = data.getNextInteger(&offset) else {
      return nil
    }
    guard let songNumber = data.getNextInteger(&offset) else {
      return nil
    }

    if let item = lookup[albumId], let album = item as? Album {
      album.addSong(self, discNumber: Int(discNumber), trackNumber: Int(songNumber))
      self.album = album
    } else {
      print("Could not look up an album for the song \(name).")
    }
  }

}
