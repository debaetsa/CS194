//
//  UnfilteredLibrary.swift
//  MusicRequests
//
//  Created by Alexander De Baets on 1/31/16.
//
//

import MediaPlayer
import UIKit

class AppleLibrary: NSObject, Library {

  let allSongs: [Song]
  let allArtists: [Artist]
  let allAlbums: [Album]
  let allPlaylists: [Playlist]
  let allGenres: [Genre]

  override init() {
    let query = MPMediaQuery.songsQuery()

    // By using the "!", we ensure that a runtime error occurs if something
    // doesn't work.  This probably shouldn't be done in production code, but
    // it should be fine for prototype and testing.
    //
    // TODO: Build in more robust error handling.
    let items = query.items!

    var songs = [Song]()  // store all the songs as they are imported

    var artists = [String: Artist]()
    var albums = [String: Album]()
    var genres = [String: Genre]()

    for item in items {
      var genre: Genre?
      if let genreName = item.genre {
        genre = genres[genreName]
        if genre == nil {
          genre = Genre(name: genreName)
          genres[genreName] = genre
        }
      }

      var artist: Artist?
      if let artistName = item.artist {
        // The artist has a name, so we want to use it with this Song.
        artist = artists[artistName]
        if artist == nil {
          // We haven't seen this artist before, so create a new entry.
          artist = Artist(name: artistName)
          artists[artistName] = artist
        }
      }

      var album: Album?
      if let albumName = item.albumTitle {
        album = albums[albumName]
        if album == nil {
          album = Album(name: albumName, artist: artist)
          albums[albumName] = album

          // We just ran code that ensures that the album exists, so it's fine
          // to unwrap the value.  If it is nil, it means that there is some
          // sort of a problem that should be corrected.  However, it's
          // possible that the artist will be nil, so we need to handle that.
          artist?.addAlbum(album!)
        }
      }

      songs.append(Song(name: item.title ?? "", artist: artist, album: album, genre: genre, discNumber: item.discNumber, trackNumber: item.albumTrackNumber, userInfo: item))
    }

    allSongs = songs.sort(Item.sorter)
    allArtists = artists.values.sort(Item.sorter)
    allAlbums = albums.values.sort(Item.sorter)
    allPlaylists = []
    allGenres = genres.values.sort(Item.sorter)

    for genre in allGenres {
      genre.didFinishImporting()
    }

    // We have to set all of our local instance variables to some value before
    // we invoke the superclass's initialization method.
    super.init()
  }
}
