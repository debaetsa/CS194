//
//  CustomAlbumArt.swift
//  MusicRequests
//
//  Created by Matthew Volk on 3/7/16.
//
//

import UIKit

class CustomAlbumArt: NSObject, Sendable {
  var album: Album // unowned for retain cycle purposes
  
  init(albumInstance: Album) {
    album = albumInstance
  }
  
  var sendableIdentifier: SendableIdentifier {
    return .Image
  }
  
  var sendableData: NSData {
    let mutableData = NSMutableData()
    mutableData.appendCustomInteger(album.identifier)
    mutableData.appendCustomImage(album.imageToShow)
    return mutableData
  }
}
