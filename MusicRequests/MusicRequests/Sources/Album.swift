//
//  Album.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//

import UIKit

class Album: Item {

  // The artists associated with all songs on this album.
  var artists: [Artist] = []

  var artist: Artist? {
    get {
      return artists.last
    }
  }

  init(name: String, sortName: String, artist: Artist?) {
    super.init(name: name, sortName: sortName)

    if let toAppend = artist {
      artists.append(toAppend)
      toAppend.addAlbum(self)
    }
  }

  convenience init(name: String, artist: Artist?) {
    self.init(name: name, sortName: name, artist: artist)
  }

  // Stores (disc, track, song) tuples.
  var songs: [(disc: Int?, track: Int?, song: Song)] = []

  func addSong(song: Song, discNumber: Int?, trackNumber: Int?) -> Void {
    print("Song: \(song.name), Disc: \(discNumber), Track: \(trackNumber)")
    songs.append((discNumber, trackNumber, song))
  }

  var allSongs: [(disc: Int?, track: Int?, song: Song)] {
    get {
      return songs.sort({ (first, second) -> Bool in
        if let disc1 = first.disc {
          if let disc2 = second.disc {
            // both have a disc number, so sort by that
            if disc1 < disc2 {
              return true
            } else if disc1 > disc2 {
              return false
            }

            // that didn't break the sort, so fall through
          } else {
            return false  // nil is before a number
          }
        } else {
          if let _ = second.disc {
            return true  // nil is before a number
          } else {
            // didn't break the sort, so fall through
          }
        }

        // do basically the same thing with tracks
        if let track1 = first.track {
          if let track2 = second.track {
            // both have a track number, so sort by that
            if track1 < track2 {
              return true
            } else if track1 > track2 {
              return false
            }

            // that didn't break the sort, so fall through
          } else {
            return false  // nil is before a number
          }
        } else {
          if let _ = second.track {
            return true  // nil is before a number
          } else {
            // didn't break the sort, so fall through
          }
        }

        return false
      })
    }
  }

}
