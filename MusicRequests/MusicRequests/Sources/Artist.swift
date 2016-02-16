//
//  Artist.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//

import UIKit

class Artist: Item {

  var albums: [Album] = []

  var singles: NSSet {
    get {
      return NSSet()
    }
  }

  func addAlbum(album: Album) {
    albums.append(album)
  }

  var allAlbums: [Album] {
    get {
      return albums.sort({ (first, second) -> Bool in
        first.date?.compare(second.date!) == NSComparisonResult.OrderedAscending
      })
    }
  }
  
  var albumCount: Int {
    get {
      return allAlbums.count
    }
  }

  func albumWithName(name: String) -> Album? {
    for album in albums {
      if album.name == name {
        return album
      }
    }
    return nil
  }
  
}
