//
//  PreviewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//
//

import UIKit

class PreviewController: UIViewController {
  
  var artist: String?
  var album: String?
  var albumArt: UIImage?
  var song: String?
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
 
    if (segue.identifier == "playerViewSegue") {
      // Create a new variable to store the instance of PlayerViewController
      let destinationVC = segue.destinationViewController as! PlayerViewController
      print ("Song name: \(song)")

      destinationVC.song = song
      destinationVC.artist = artist
      destinationVC.album = album
    } else if (segue.identifier == "albumArtSegue") {
      let destinationVC = segue.destinationViewController as! ImagePreviewController
      print ("Album art: \(albumArt)")
      destinationVC.albumArt =  albumArt
    }
  }

}
