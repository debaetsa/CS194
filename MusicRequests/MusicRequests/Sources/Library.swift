//
//  Library.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

protocol Library {

  var songs: [Song] { get }
  
  var artists: [Artist] { get }
  
  var albums: [Album] { get }

  var playlists: [Playlist] { get }

  var genres: [Genre] { get }

}
