//
//  Library.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class Library: NSObject {
  
  //Was making all the getters/setters here necessary? In the other classes I just accessed their variables because I have not yet put restritions on them. I think we should have getter and setters and keep everything private though, what do you think? I was having an issue with getting and setting syntax not playing well with the automatically generated files. I could only get it to would if I made a normal function to do it.
  
  //Also I added the setters so I could play with it in the Test class.
  
  var songs: [Song] {
    get {
      return self.songs
    }
    set {
      self.songs = newValue
    }
  }
  
  var artists: [Artist] {
    get {
      return self.artists
    }
    set {
      self.artists = newValue
    }
  }
  
  var albums: [Album] {
    get {
      return self.albums
    }
    set {
      self.albums = newValue
    }
  }
  
  var playlists: [Playlist] {
    get {
      return self.playlists
    }
    set {
      self.playlists = newValue
    }
  }
  
  var genres: [Genre] {
    get {
      return self.genres
    }
    set {
      self.genres = newValue
    }
  }
  
}
