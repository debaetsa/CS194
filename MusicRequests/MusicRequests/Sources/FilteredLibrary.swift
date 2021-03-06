//
//  FilteredLibrary.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class FilteredLibrary: Library {

  private let songs: [Song]
  override var allSongs: [Song] { return songs }
  private let artists: [Artist]
  override var allArtists: [Artist] { return artists }
  private let albums: [Album]
  override var allAlbums: [Album] { return albums }
  private let genres: [Genre]
  override var allGenres: [Genre] { return genres }

  private var lookup = [UInt32: Item]()

  let playlist: Playlist

  init(playlist: Playlist) {
    self.playlist = playlist

    // we need to recreate the Library based on the Song contents
    var mappedAlbums = [Album: Album]()
    var mappedArtists = [Artist: Artist]()
    var mappedGenres = [Genre: Genre]()
    var mappedAlbumArtists = Set<Artist>()
    var mappedSongs = [Song]()

    for song in playlist.allSongs {
      // make sure we have the Album and Artist for each Song
      var mappedAlbum: Album? = nil

      if let album = song.album {
        if let existingMappedAlbum = mappedAlbums[album] {
          // this album (and its corresponding Artist) are already mapped
          mappedAlbum = existingMappedAlbum

        } else {
          // we haven't yet mapped this album, so map it now
          mappedAlbum = album.shallowCopy()
          mappedAlbums[album] = mappedAlbum  // save it for later

          // now that we have mapped the Album, we need to map its Artist
          var mappedArtist: Artist? = nil

          if let artist = album.artist {
            if let existingMappedArtist = mappedArtists[artist] {
              mappedArtist = existingMappedArtist

            } else {
              // create the copy and save it for later
              mappedArtist = artist.shallowCopy()
              mappedArtists[artist] = mappedArtist
            }

            // We need to make sure that this Artist is marked as one that
            // should appear in the list.
            mappedAlbumArtists.insert(mappedArtist!)
          }

          // connect the artist to the Album
          if let boundMappedArtist = mappedArtist {
            mappedAlbum?.addArtist(boundMappedArtist)
          }
        }
      }

      // At this point, we have the Album reference that we are meant to use
      // for this Song.  We next need to ensure that we have an updated
      // artistOverride reference, which we may have and which we also may need
      // to create.
      var mappedArtistOverride: Artist? = nil

      if let artist = song.artistOverride {
        if let existingMappedArtist = mappedArtists[artist] {
          mappedArtistOverride = existingMappedArtist

        } else {
          mappedArtistOverride = artist.shallowCopy()
          mappedArtists[artist] = mappedArtistOverride
        }
      }

      // Get the mapped Genre.  This one should be pretty easy.
      var mappedGenre: Genre? = nil

      if let genre = song.genre {
        if let existingMappedGenre = mappedGenres[genre] {
          mappedGenre = existingMappedGenre

        } else {
          mappedGenre = genre.shallowCopy()
          mappedGenres[genre] = mappedGenre
        }
      }

      // Finally, we can create the new Song object and add it to the list that
      // we are constructing.  We'll get Artists/Albums later.
      let track = song.album?.trackForSong(song)
      let filteredSong = Song(
        name: song.name,
        artist: mappedArtistOverride,
        album: mappedAlbum,
        genre: mappedGenre,
        discNumber: track?.disc,
        trackNumber: track?.track,
        userInfo: song.userInfo
      )

      mappedSongs.append(filteredSong)
      lookup[filteredSong.identifier] = filteredSong
    }

    songs = mappedSongs.sort(Item.sorter)
    artists = Array(mappedAlbumArtists).sort(Item.sorter)
    albums = mappedAlbums.values.sort(Item.sorter)
    genres = mappedGenres.values.sort(Item.sorter)

    // initialize the superclass
    super.init()

    // we have loaded everything at this point
    finishLoading()
  }

  override func itemForIdentifier(identifier: UInt32) -> Item? {
    return lookup[identifier]
  }
}
