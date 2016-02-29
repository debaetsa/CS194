//
//  QueueViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/29/16.
//
//

import UIKit

class QueueViewController: UIViewController {

  
  
  @IBOutlet weak var playButton: UIBarButtonItem!
  
  @IBAction func prevButtonPressed(sender: AnyObject) {
    let upNextVC = self.childViewControllers[0] as! UpNextTableViewController
    upNextVC.getQueue().nowPlaying.last()
  }
  
  @IBAction func playButtonPressed(sender: AnyObject) {
    let upNextVC = self.childViewControllers[0] as! UpNextTableViewController
    let queue = upNextVC.getQueue()
    if (queue.nowPlaying.isPlaying) {
      queue.nowPlaying.pause()
      playButton.image = UIImage(named: "play_button")
    } else {
      queue.nowPlaying.play()
      playButton.image = UIImage(named: "pause_button")
    }
  }
  
  @IBAction func nextButtonPressed(sender: AnyObject) {
    let upNextVC = self.childViewControllers[0] as! UpNextTableViewController
    upNextVC.queue.nowPlaying.next()
  }
  
  override func viewDidAppear(animated: Bool) {
    let upNextVC = self.childViewControllers[0] as! UpNextTableViewController
    if (upNextVC.getQueue().nowPlaying.isPlaying){
      playButton.image = UIImage(named: "pause_button")
    } else {
      playButton.image = UIImage(named: "play_button")
    }
  }

}
