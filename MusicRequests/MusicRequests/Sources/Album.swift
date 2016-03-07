//
//  Album.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//

import UIKit

typealias Track = (disc: Int?, track: Int?, song: Song)

class Album: Item {

  // The artists associated with all songs on this album.
  var artists: [Artist] = []
  
  var artist: Artist? {
    return artists.last
  }

  var image: UIImage?
  var date: NSDate?
  var imageToShow: UIImage {
    return image ?? UIImage(named: "NoAlbumArtwork")!
  }

  init(name: String, sortName: String, artist: Artist?, date: NSDate?) {
    super.init(name: name, sortName: sortName)

    if let toAppend = artist {
      addArtist(toAppend)
    }
  }
  
  init(name: String, sortName: String, artist: Artist?) {
    super.init(name: name, sortName: sortName)
    
    if let toAppend = artist {
      addArtist(toAppend)
    }
  }
  
  convenience init(name: String, artist: Artist?) {
    self.init(name: name, sortName: name, artist: artist)
  }

  convenience init(name: String, artist: Artist?, date: NSDate?) {
    self.init(name: name, sortName: name, artist: artist, date: date)
  }

  private func addArtist(artist: Artist) {
    artists.append(artist)
    artist.addAlbum(self)
  }

  // Stores (disc, track, song) tuples.
  var songs: [Track] = []

  func addSong(song: Song, discNumber: Int?, trackNumber: Int?) -> Void {
    songs.append((discNumber, trackNumber, song))
  }

  func trackForSong(song: Song) -> Track? {
    for track in songs {
      if track.song === song {
        return track
      }
    }
    return nil
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

  // MARK: - Sending

  override var tag: Tag {
    return .Album
  }

  override func buildSendableData(mutableData: NSMutableData) {
    super.buildSendableData(mutableData)

    // and then append the extra information that we need here (the Artist)
    mutableData.appendCustomInteger(self.artist?.identifier ?? UInt32(0))
    if let boundImage = image {
      let imageData = UIImageJPEGRepresentation(boundImage, 0.1)
      let imageSize = imageData?.length
      mutableData.appendCustomInteger(UInt32(imageSize ?? 0))
      mutableData.appendData(imageData!)
    } else {
      mutableData.appendCustomInteger(UInt32(0))
    }
  }

  required init?(data: NSData, lookup: [UInt32: Item], inout offset: Int) {
    super.init(data: data, lookup: lookup, offset: &offset)

    guard let artistId = data.getNextInteger(&offset) else {
      return nil
    }
    
    image = data.getNextImage(&offset)

    if let item = lookup[artistId], let artist = item as? Artist {
      addArtist(artist)
    } else {
      print("Failed to look up artist for album \(name).")
    }
  }

}
