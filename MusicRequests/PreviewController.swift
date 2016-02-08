//
//  PreviewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//
//

import UIKit

class PreviewController: UIViewController {
  
  var song: Song?
  var artist: Artist?
  var album: Album?
  
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
      destinationVC.albumArt =  album!.imageToShow
    }
  }

}
