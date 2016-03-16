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
  override var allSongs: [Song] {
    return songs
  }

  private var artists = [Artist]()
  override var allArtists: [Artist] {
    return artists
  }

  private var albums = [Album]()
  override var allAlbums: [Album] {
    return albums
  }

  private var playlists = [Playlist]()
  override var allPlaylists: [Playlist] {
    return playlists
  }

  private var genres = [Genre]()
  override var allGenres: [Genre] {
    return genres
  }

  init(receivedGloballyUniqueIdentifier: NSUUID) {
    super.init(
      globallyUniqueIdentifier: receivedGloballyUniqueIdentifier
    )
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
      logger("could not parse \(T.description()) from \(data)")
    }
    return maybeItem
  }

  func addItemFromData(data: NSData) -> Bool {
    var offset = 0

    guard let rawValue = data.getNextByte(&offset) else {
      return false
    }
    guard let type = Item.Tag(rawValue: rawValue) else {
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
      logger("ignoring item of type \(type)")
    }

    if let item = maybeItem {
      identifierToItem[item.identifier] = item
    }

    return true
  }

  // Receive Image type
  func updateFromData(data: NSData, usingLibrary library: RemoteLibrary) -> Bool {
    var offset = 0
    
    guard let albumIdentifier = data.getNextInteger(&offset) else {
      return false
    }
    guard let image = data.getNextImage(&offset) else {
      return false
    }
    guard let item = library.itemForIdentifier(albumIdentifier) else {
      return false
    }
    guard let album = item as? Album else {
      return false
    }

    album.image = image

    return true
  }
}
