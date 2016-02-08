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
  
  @IBOutlet weak var songLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    populateLabels()
  }
  
  func populateLabels() {
    songLabel.text = song
    
    var detailComponents = [String]()
    if artist != nil {
      detailComponents.append(artist!)
    }
    if album != nil {
      detailComponents.append(album!)
    }
    detailLabel.text = detailComponents.joinWithSeparator(" • ")
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
