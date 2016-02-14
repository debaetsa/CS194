//
//  ItemPresentation.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/9/16.
//
//

import Foundation

extension Song {
  var artistAlbumString: String {
    var components = [String]()
    if let name = self.artist?.name {
      components.append(name)
    }
    if let name = self.album?.name {
      components.append(name)
    }
    return components.joinWithSeparator(" • ")
  }
}
