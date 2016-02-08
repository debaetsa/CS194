//
//  PlayerViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//
//

import UIKit

class PlayerViewController: PreviewController {
  let nowPlaying = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.nowPlaying)!
  
  @IBOutlet weak var SongTitle: UILabel!
  @IBOutlet weak var ArtistAlbum: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SongTitle.text = song
  }
  
  
  @IBAction func backButtonIsPressed(sender: UIButton) {
    nowPlaying.last()
  }
  
  @IBAction func playButtonIsPressed(sender: UIButton) {
    nowPlaying.play()
  }
  
  @IBAction func nextButtonIsPressed(sender: UIButton) {
    nowPlaying.next()
  }
  
  @IBAction func scrubberIsUsed(sender: AnyObject) {
    nowPlaying.scrub()
  }
  
}
