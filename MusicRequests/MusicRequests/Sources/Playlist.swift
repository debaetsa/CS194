//
//  Playlist.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//

import Foundation
import CoreData


class Playlist: NSManagedObject {

  // we're going to want to pull this out into another class for reuse by the album class. I don't know how you want to deal with the whole idea of a "disc" in an album. In addition, this will NOT return the songs in an order playlist, so we need to talk about how we want to do that. I don't want to create an array with null cell though, that sounds awful to me but it may be our best bet.
  
  //this is also a prime example of the optional fields causing problems. Especially when I did not know what the ! meant.
  
  func getSongs() -> [Song] {
    var songs = [Song]();
    for track in tracks! {
      songs.append((track as! Track).song!)
    }
    return songs;
  }
  
}

