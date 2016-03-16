//
//  TemporaryLibrary.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/30/16.
//
//

import UIKit

class TemporaryLibrary: Library {

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

  init() {
    // Create arrays to hold the data as we add it.
    var artists = [Artist]()
    var albums = [Album]()
    var songs = [Song]()

    var album: Album?
    var artist: Artist?

    // Then start actually creating and loading the data.

    // a-ha
    artist = Artist(name: "a-ha")
    artists.append(artist!)

    album = Album(name: "Hunting High and Low", artist: artist)
    albums.append(album!)

    songs.append(Song(name: "Take On Me", artist: artist, album: album, discNumber: nil, trackNumber: 1))


    // Garth Brooks, Double Live
    artist = Artist(name: "Garth Brooks")
    artists.append(artist!)

    album = Album(name: "Double Live", artist: artist)
    albums.append(album!)


    songs.append(Song(name: "Callin' Baton Rouge", artist: artist, album: album, discNumber: 1, trackNumber: 1))
    songs.append(Song(name: "Two Of A Kind, Workin' On A Full House", artist: artist, album: album, discNumber: 1, trackNumber: 2))
    songs.append(Song(name: "Shameless", artist: artist, album: album, discNumber: 1, trackNumber: 3))
    songs.append(Song(name: "Papa Loved Mama", artist: artist, album: album, discNumber: 1, trackNumber: 4))
    songs.append(Song(name: "The Thunder Rolls (The Long Version)", sortName: "Thunder Rolls", artist: artist, album: album, discNumber: 1, trackNumber: 5))
    songs.append(Song(name: "We Shall Be Free", artist: artist, album: album, discNumber: 1, trackNumber: 6))
    songs.append(Song(name: "Unanswered Prayers", artist: artist, album: album, discNumber: 1, trackNumber: 7))
    songs.append(Song(name: "Standing Outside The Fire", artist: artist, album: album, discNumber: 1, trackNumber: 8))
    songs.append(Song(name: "Longneck Bottle", artist: artist, album: album, discNumber: 1, trackNumber: 9))
    songs.append(Song(name: "It's Your Song", artist: artist, album: album, discNumber: 1, trackNumber: 10))
    songs.append(Song(name: "Much Too Young (To Feel This Damn Old)", artist: artist, album: album, discNumber: 1, trackNumber: 11))
    songs.append(Song(name: "The River", sortName: "River", artist: artist, album: album, discNumber: 1, trackNumber: 12))
    songs.append(Song(name: "Untitled", artist: artist, album: album, discNumber: 1, trackNumber: 13))
    songs.append(Song(name: "Tearin' It Up (And Burnin' It Down)", artist: artist, album: album, discNumber: 1, trackNumber: 14))
    songs.append(Song(name: "Ain't Goin' Down ('Til The Sun Comes Up)", artist: artist, album: album, discNumber: 2, trackNumber: 1))
    songs.append(Song(name: "Rodeo", artist: artist, album: album, discNumber: 2, trackNumber: 2))
    songs.append(Song(name: "The Beaches Of Cheyenne", sortName: "Beaches of Cheyenne", artist: artist, album: album, discNumber: 2, trackNumber: 3))
    songs.append(Song(name: "Two Piña Coladas", artist: artist, album: album, discNumber: 2, trackNumber: 4))
    songs.append(Song(name: "Wild As The Wind", artist: artist, album: album, discNumber: 2, trackNumber: 5))
    songs.append(Song(name: "To Make You Feel My Love", artist: artist, album: album, discNumber: 2, trackNumber: 6))
    songs.append(Song(name: "That Summer", artist: artist, album: album, discNumber: 2, trackNumber: 7))
    songs.append(Song(name: "American Honky-Tonk Bar Assocation", artist: artist, album: album, discNumber: 2, trackNumber: 8))
    songs.append(Song(name: "If Tomorrow Never Comes", artist: artist, album: album, discNumber: 2, trackNumber: 9))
    songs.append(Song(name: "The Fever", sortName: "Fever", artist: artist, album: album, discNumber: 2, trackNumber: 10))
    songs.append(Song(name: "Friends In Low Places (The Long Version)", artist: artist, album: album, discNumber: 2, trackNumber: 11))
    songs.append(Song(name: "The Dance", sortName: "Dance", artist: artist, album: album, discNumber: 2, trackNumber: 12))

    // Adele, 21
    artist = Artist(name: "Adele")
    artists.append(artist!)

    album = Album(name: "21", artist: artist)
    albums.append(album!)

    songs.append(Song(name: "Rolling In The Deep", artist: artist, album: album, discNumber: nil, trackNumber: 1))
    songs.append(Song(name: "Rumour Has It", artist: artist, album: album, discNumber: nil, trackNumber: 2))
    songs.append(Song(name: "Turning Tables ", artist: artist, album: album, discNumber: nil, trackNumber: 3))
    songs.append(Song(name: "Don't You Remember ", artist: artist, album: album, discNumber: nil, trackNumber: 4))
    songs.append(Song(name: "Set Fire To The Rain ", artist: artist, album: album, discNumber: nil, trackNumber: 5))
    songs.append(Song(name: "He Won't Go", artist: artist, album: album, discNumber: nil, trackNumber: 6))
    songs.append(Song(name: "Take It All", artist: artist, album: album, discNumber: nil, trackNumber: 7))
    songs.append(Song(name: "I'll Be Waiting", artist: artist, album: album, discNumber: nil, trackNumber: 8))
    songs.append(Song(name: "One And Only ", artist: artist, album: album, discNumber: nil, trackNumber: 9))
    songs.append(Song(name: "Lovesong", artist: artist, album: album, discNumber: nil, trackNumber: 10))
    songs.append(Song(name: "Someone Like You", artist: artist, album: album, discNumber: nil, trackNumber: 11))


    artist = Artist(name: "Bruce Springsteen")
    artists.append(artist!)

    album = Album(name: "Born to Run", artist: artist)
    albums.append(album!)

    songs.append(Song(name: "Tenth Avenue Freeze-Out", artist: artist, album: album, discNumber: nil, trackNumber: 2))

    album = Album(name: "Greatest Hits", artist: artist)
    albums.append(album!)

    songs.append(Song(name: "The River", sortName: "River", artist: artist, album: album, discNumber: nil, trackNumber: 4))
    songs.append(Song(name: "Hungry Heart", artist: artist, album: album, discNumber: nil, trackNumber: 5))
    songs.append(Song(name: "Dancing In the Dark", artist: artist, album: album, discNumber: nil, trackNumber: 7))
    songs.append(Song(name: "Human Touch", artist: artist, album: album, discNumber: nil, trackNumber: 12))
    songs.append(Song(name: "Murder Incorporated", artist: artist, album: album, discNumber: nil, trackNumber: 16))
    songs.append(Song(name: "Born to Run", artist: artist, album: album, discNumber: nil, trackNumber: 1))
    songs.append(Song(name: "Thunder Road ", artist: artist, album: album, discNumber: nil, trackNumber: 2))
    songs.append(Song(name: "Badlands ", artist: artist, album: album, discNumber: nil, trackNumber: 3))
    songs.append(Song(name: "Atlantic City", artist: artist, album: album, discNumber: nil, trackNumber: 6))
    songs.append(Song(name: "Born In The U.S.A. ", artist: artist, album: album, discNumber: nil, trackNumber: 8))
    songs.append(Song(name: "My Hometown", artist: artist, album: album, discNumber: nil, trackNumber: 9))
    songs.append(Song(name: "Glory Days ", artist: artist, album: album, discNumber: nil, trackNumber: 10))
    songs.append(Song(name: "Brilliant Disguise ", artist: artist, album: album, discNumber: nil, trackNumber: 11))
    songs.append(Song(name: "Better Days", artist: artist, album: album, discNumber: nil, trackNumber: 13))
    songs.append(Song(name: "Streets of Philadelphia", artist: artist, album: album, discNumber: nil, trackNumber: 14))
    songs.append(Song(name: "Secret Garden", artist: artist, album: album, discNumber: nil, trackNumber: 15))
    songs.append(Song(name: "Blood Brothers ", artist: artist, album: album, discNumber: nil, trackNumber: 17))
    songs.append(Song(name: "This Hard Land ", artist: artist, album: album, discNumber: nil, trackNumber: 18))

    album = Album(name: "Greetings from Asbury Park, N.J.", artist: artist)
    albums.append(album!)

    songs.append(Song(name: "Blinded By the Light", artist: artist, album: album, discNumber: nil, trackNumber: 1))

    self.songs = songs.sort(Item.sorter)
    self.artists = artists.sort(Item.sorter)
    self.albums = albums.sort(Item.sorter)
    self.playlists = []
    self.genres = []

    super.init()

    finishLoading()
  }

}
