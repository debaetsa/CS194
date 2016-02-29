//
//  QueueViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/29/16.
//
//

import UIKit

class QueueViewController: UITableViewController {

  @IBOutlet weak var playButton: UIBarButtonItem!
  
  @IBAction func prevButtonPressed(sender: AnyObject) {
//    self.queue.nowPlaying.last()
  }
  
  @IBAction func playButtonPressed(sender: AnyObject) {
//    if (self.queue.nowPlaying.isPlaying) {
//      self.queue.nowPlaying.pause()
//      playButton.image = UIImage(named: "play_button")
//    } else {
//      self.queue.nowPlaying.play()
//      playButton.image = UIImage(named: "pause_button")
//    }
  }
  
  @IBAction func nextButtonPressed(sender: AnyObject) {
//    self.queue.nowPlaying.next()
  }
  
  override func viewDidAppear(animated: Bool) {
    let upNextVC = self.childViewControllers[0]
    print ("ChildViewControllers: \(upNextVC)")
//    print ("queue playing: \(upNextVC.isPlaying())")
//    self.updateData()
//    self.tableView.reloadData()
//    if (self.queue.nowPlaying.isPlaying){
//      playButton.image = UIImage(named: "pause_button")
//    } else {
//      playButton.image = UIImage(named: "play_button")
//    }
  }

}
