//
//  UnfilteredLibrary.swift
//  MusicRequests
//
//  Created by Alexander De Baets on 1/31/16.
//
//

import MediaPlayer
import UIKit

class AppleLibrary: Library {

  let songs: [Song]
  override var allSongs: [Song] { return songs }
  let artists: [Artist]
  override var allArtists: [Artist] { return artists }
  let albums: [Album]
  override var allAlbums: [Album] { return albums }
  let playlists: [Playlist]
  override var allPlaylists: [Playlist] { return playlists }
  let genres: [Genre]
  override var allGenres: [Genre] { return genres }

  let lookup: [UInt32: Item]

  init() {
    let query = MPMediaQuery.songsQuery()

    // By using the "!", we ensure that a runtime error occurs if something
    // doesn't work.  This probably shouldn't be done in production code, but
    // it should be fine for prototype and testing.
    //
    // TODO: Build in more robust error handling.
    let items = query.items!

    var songs = [Song]()  // store all the songs as they are imported

    var playlists = [Playlist]()
    var albumArtists = [String: Artist]()
    var songArtists = [String: Artist]()
    var albums = [Album]()
    var genres = [String: Genre]()
    var idToSong = [MPMediaEntityPersistentID: Song]()
    var lookup = [UInt32: Item]()

    for item in items {
      var genre: Genre?
      if let genreName = item.genre {
        genre = genres[genreName]
        if genre == nil {
          genre = Genre(name: genreName)
          genres[genreName] = genre
        }
      }

      let artistNameForAlbum: String
      if let albumArtistName = item.albumArtist {
        artistNameForAlbum = albumArtistName
      } else {
        // If it's a compilation, use "Various Artists".
        if let artistName = item.artist where !item.compilation {
          artistNameForAlbum = artistName
        } else {
          artistNameForAlbum = "Various Artists"
        }
      }

      // Set to the "unique" name for the (artist, album) pair.  Will depend on
      // the album artist, "is compilation?" flag, and the artist.
      var artistForAlbum: Artist! = albumArtists[artistNameForAlbum]
      if artistForAlbum == nil {
        artistForAlbum = songArtists[artistNameForAlbum]
        albumArtists[artistNameForAlbum] = artistForAlbum
      }
      if artistForAlbum == nil {
        // We haven't seen this artist before, so create a new entry.
        artistForAlbum = Artist(name: artistNameForAlbum)
        albumArtists[artistNameForAlbum] = artistForAlbum
      }


      var maybeArtistNameForSong: String? = nil
      if let artistName = item.artist {
        if artistName != artistNameForAlbum {
          maybeArtistNameForSong = artistName
        }
      }

      // Set the the name for the artist for the Song, but only if it should be
      // overridden from the artist for the album.
      var artistForSong: Artist? = nil
      if let artistNameForSong = maybeArtistNameForSong {
        artistForSong = songArtists[artistNameForSong]
        if artistForSong == nil {
          artistForSong = albumArtists[artistNameForSong]
        }
        if artistForSong == nil {
          artistForSong = Artist(name: artistNameForSong)
          songArtists[artistNameForSong] = artistForSong
        }
      }

      var album: Album?
      if let albumName = item.albumTitle {
        album = artistForAlbum.albumWithName(albumName)
        if album == nil {
          // We couldn't find the album, or there wasn't an artist.
          let boundAlbum = Album(name: albumName, artist: artistForAlbum, date: item.releaseDate)
          album = boundAlbum
          albums.append(boundAlbum)
        }
      }

      if let boundAlbum = album {
        if boundAlbum.image == nil {
          boundAlbum.image = item.artwork?.imageWithSize(CGSize(width: 100, height: 100))
        }
      }

      let song = Song(name: item.title ?? "", artist: artistForSong, album: album, genre: genre, discNumber: item.discNumber, trackNumber: item.albumTrackNumber, userInfo: item)
      lookup[song.identifier] = song
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
            logger("could not find song with name \(item.title) and ID \(item.persistentID)")
          }
        }

        // TODO: Maybe we want to skip empty playlists.
        playlists.append(playlist)
      }
    }

    self.songs = songs.sort(Item.sorter)
    self.artists = albumArtists.values.sort(Item.sorter)
    self.albums = albums.sort(Item.sorter)
    self.playlists = playlists.sort(Item.sorter)
    self.genres = genres.values.sort(Item.sorter)
    self.lookup = lookup

    for genre in self.genres {
      genre.didFinishImporting()
    }

    // We have to set all of our local instance variables to some value before
    // we invoke the superclass's initialization method.
    super.init()

    finishLoading()  // this is loaded at this point
  }
}
