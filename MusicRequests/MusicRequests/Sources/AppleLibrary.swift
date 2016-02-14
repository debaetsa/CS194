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

    var playlists = [Playlist]()
    var artists = [String: Artist]()
    var albums = [Album]()
    var genres = [String: Genre]()
    var idToSong = [MPMediaEntityPersistentID: Song]()

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
        if let boundArtist = artist {
          album = boundArtist.albumWithName(albumName)
        }
        if album == nil {
          // We couldn't find the album, or there wasn't an artist.
          let boundAlbum = Album(name: albumName, artist: artist)
          album = boundAlbum
          albums.append(boundAlbum)
        }
      }

      if let boundAlbum = album {
        if boundAlbum.image == nil {
          boundAlbum.image = item.artwork?.imageWithSize(CGSize(width: 100, height: 100))
          item.artwork
        }
      }

      let song = Song(name: item.title ?? "", artist: artist, album: album, genre: genre, discNumber: item.discNumber, trackNumber: item.albumTrackNumber, userInfo: item)
      songs.append(song)
      idToSong[item.persistentID] = song
    }

    // After importing everything from the library, we can go through and
    // associate them with the playlists on the device.
    let playlistQuery = MPMediaQuery.playlistsQuery()
    playlistQuery.groupingType = MPMediaGrouping.Playlist

    let playlistItemCollections = playlistQuery.collections!


    for collection in playlistItemCollections {
      if let playlistName = (collection.valueForProperty(MPMediaPlaylistPropertyName) as? String) {
        // We have a valid name for the Playlist, so create a Playlist.
        let playlist = Playlist(name: playlistName)

        for item in collection.items {
          if let song = idToSong[item.persistentID] {
            playlist.addSong(song)
          } else {
            print("Could not find Song for entry in playlist.")
          }
        }

        // TODO: Maybe we want to skip empty playlists.
        playlists.append(playlist)
      }
    }

    allSongs = songs.sort(Item.sorter)
    allArtists = artists.values.sort(Item.sorter)
    allAlbums = albums.sort(Item.sorter)
    allPlaylists = playlists.sort(Item.sorter)
    allGenres = genres.values.sort(Item.sorter)

    for genre in allGenres {
      genre.didFinishImporting()
    }

    // We have to set all of our local instance variables to some value before
    // we invoke the superclass's initialization method.
    super.init()
  }
}
