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
    let imageData = UIImageJPEGRepresentation(album.imageToShow, 0.1)
    let imageSize = imageData?.length
    mutableData.appendCustomInteger(UInt32(imageSize ?? 0))
    mutableData.appendData(imageData!)
    return mutableData
  }
}
