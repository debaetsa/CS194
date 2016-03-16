//
//  QueueViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/29/16.
//
//

import UIKit

class QueueViewController: UIViewController {
  
  let playButtonFile = "play_button"
  let pauseButtonFile = "pause_button"
  let addSongButtonFile = "temp_plus_button"
  
  @IBOutlet weak var addSongButton: UIButton!
  @IBOutlet weak var playButton: UIBarButtonItem!
  
  @IBAction func prevButtonPressed(sender: AnyObject) {
    let upNextVC = self.childViewControllers[0] as! UpNextTableViewController
    ((upNextVC.maybeQueue as! LocalQueue).nowPlaying as! LocalNowPlaying).last()
  }
  
  @IBAction func playButtonPressed(sender: AnyObject) {
    let upNextVC = self.childViewControllers[0] as! UpNextTableViewController
    let nowPlaying = (upNextVC.maybeQueue as! LocalQueue).nowPlaying as! LocalNowPlaying
    if (nowPlaying.isPlaying) {
      nowPlaying.pause()
      playButton.image = UIImage(named: playButtonFile)
    } else {
      nowPlaying.play()
      playButton.image = UIImage(named: pauseButtonFile)
    }
  }
  
  @IBAction func nextButtonPressed(sender: AnyObject) {
    let upNextVC = self.childViewControllers[0] as! UpNextTableViewController
    let nowPlaying = (upNextVC.maybeQueue as! LocalQueue).nowPlaying as! LocalNowPlaying
    nowPlaying.next()
  }
  
  override func viewDidAppear(animated: Bool) {
    let upNextVC = self.childViewControllers[0] as! UpNextTableViewController
    let maybeLocalQueue = upNextVC.maybeQueue as? LocalQueue
    if (maybeLocalQueue != nil) && (maybeLocalQueue!.nowPlaying as! LocalNowPlaying).isPlaying {
      playButton.image = UIImage(named: pauseButtonFile)
    } else {
      playButton.image = UIImage(named: playButtonFile)
    }
  }
}
