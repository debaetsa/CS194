//
//  PlayerViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//
//

import UIKit

class PlayerViewController: PreviewController {

  
  @IBOutlet weak var SongTitle: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SongTitle.text = song
  }
  
  @IBOutlet weak var ArtistAlbum: UILabel!

}
