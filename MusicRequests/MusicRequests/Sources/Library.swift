//
//  Library.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

protocol Library {

  var allSongs: [Song] { get }
  
  var allArtists: [Artist] { get }
  
  var allAlbums: [Album] { get }

  var allPlaylists: [Playlist] { get }

  var allGenres: [Genre] { get }

}
