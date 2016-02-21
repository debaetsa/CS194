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

  /** Looks up an Item based on its identifier. */
  func itemForIdentifier(identifier: UInt32) -> Item? {
    return identifierToItem[identifier]
  }

  func tryToAddItem<T: Item>(data: NSData, inout withOffset offset: Int, inout toArray array: [T]) -> T? {
    let maybeItem = T(data: data, lookup: identifierToItem, offset: &offset)
    if let item = maybeItem {
      array.append(item)
    } else {
      print("Could not parse item of type \(T.description())")
    }
    return maybeItem
  }

  func addItemFromData(data: NSData) -> Bool {
    var offset = 0

    guard let rawValue = data.getNextByte(&offset) else {
      print("Could not read a byte.")
      return false
    }
    guard let type = Item.Tag(rawValue: rawValue) else {
      print("Not a valid type: \(rawValue)")
      return false
    }

    var maybeItem: Item?

    switch type {
    case .Artist:
      maybeItem = tryToAddItem(data, withOffset: &offset, toArray: &artists)

    case .Album:
      maybeItem = tryToAddItem(data, withOffset: &offset, toArray: &albums)

    case .Song:
      maybeItem = tryToAddItem(data, withOffset: &offset, toArray: &songs)

    default:
      print("Ignoring item of type \(type).")
    }

    if let item = maybeItem {
      identifierToItem[item.identifier] = item
    }

    return true
  }

}
