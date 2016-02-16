//
//  RemoteLibrary.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class RemoteLibrary: Library {

  /** Maps identifiers to items for building relationships. */
  private var identifierToItem = [UInt32: Item]()

  private var songs = [Song]()
  var allSongs: [Song] {
    return songs
  }

  private var artists = [Artist]()
  var allArtists: [Artist] {
    return artists
  }

  private var albums = [Album]()
  var allAlbums: [Album] {
    return albums
  }

  private var playlists = [Playlist]()
  var allPlaylists: [Playlist] {
    return playlists
  }

  private var genres = [Genre]()
  var allGenres: [Genre] {
    return genres
  }

  func addItemFromData(data: NSData) {
    let length = data.length
    guard length >= 1 else {
      print("Ignoring item because there is no data.")
      return
    }

    var type = Item.Tag.Item  // use a default value
    withUnsafeMutablePointer(&type) {
      data.getBytes(UnsafeMutablePointer($0), length: sizeofValue(type))
    }

    var maybeItem: Item?

    switch type {
    case .Artist:
      let artist = Artist(data: data, lookup: identifierToItem)
      maybeItem = artist
      artists.append(artist)

    case .Album:
      let album = Album(data: data, lookup: identifierToItem)
      maybeItem = album
      albums.append(album)

    case .Song:
      let song = Song(data: data, lookup: identifierToItem)
      maybeItem = song
      songs.append(song)

    default:
      print("Ignoring item of type \(type).")
    }

    if let item = maybeItem {
      identifierToItem[item.identifier] = item
    }
  }

}
