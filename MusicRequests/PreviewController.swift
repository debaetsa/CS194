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
  var song: String?
  
  override func viewDidLoad() {
    print ("song title \(song)")
  
  }
  
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
 
    if (segue.identifier == "playerViewSegue") {
      // Create a new variable to store the instance of PlayerViewController
      let destinationVC = segue.destinationViewController as! PlayerViewController
      destinationVC.song = song
    }
  }

}
