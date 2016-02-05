//
//  UnfilteredLibrary.swift
//  MusicRequests
//
//  Created by Alexander De Baets on 1/31/16.
//
//

import MediaPlayer
import UIKit

class UnfilteredLibrary: Library {
  
  var allSongs: [Song]
  var allArtists: [Artist]
  var allAlbums: [Album]
  var allPlaylists: [Playlist]
  var allGenres: [Genre]


  init() {
    let query = MPMediaQuery.songsQuery()
    let items = query.items!
    var songs = [Song]()
    
    var artistsDict = [String: Artist]()
    var albumDict = [String: Album]()
    var genresDict = [String: Genre]()
    
    for item in items {
      
      var artist: Artist
      if artistsDict.keys.contains(item.artist!) {
        artist = artistsDict[item.artist!]!
      } else {
        artist = Artist(name: item.artist!)
        artistsDict[item.artist!] = artist
      }
      
      var album: Album
      if albumDict.keys.contains(item.albumTitle!) {
        album = albumDict[item.albumTitle!]!
      } else {
        album = Album(name: item.albumTitle!, artist: artist)
        albumDict[item.albumTitle!] = album
      }
      
      artist.addAlbum(album)
      
      var genre: Genre
      if genresDict.keys.contains(item.genre!) {
        genre = genresDict[item.genre!]!
      } else {
        genre = Genre(name: item.genre!)
        genresDict[item.genre!] = genre
      }
      
      let song = Song(name: item.title!, artist: artist, album: album, discNumber: item.discNumber, trackNumber: item.albumTrackNumber)
      
      songs.append(song)
    }

    allPlaylists = []
    allSongs = songs
    allArtists = artistsDict.values.sort({$0.name < $1.name})
    allAlbums = albumDict.values.sort({$0.name < $1.name})
    allGenres = genresDict.values.sort({$0.name < $1.name})
  }
}