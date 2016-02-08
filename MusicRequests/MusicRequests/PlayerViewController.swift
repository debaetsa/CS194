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
  
  @IBAction func buttonIsPressed(sender: AnyObject) {
    let tag = sender.tag
    print ("tag: \(tag)")
    switch tag {
    case 1: nowPlaying.play()
    case 2: nowPlaying.next()
    case 3: nowPlaying.last()
    case 4: nowPlaying.scrub()
    default: break
    }
  }

}
