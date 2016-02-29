//
//  PlayerViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//
//

import UIKit

class NowPlayingViewController: SongViewController {

  @IBOutlet weak var playButton: UIButton!
  let nowPlaying = AppDelegate.sharedDelegate.nowPlaying
  var listener: NSObjectProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()

    let center = NSNotificationCenter.defaultCenter()
    listener = center.addObserverForName(Queue.didChangeNowPlayingNotification, object: nowPlaying.queue, queue: nil) { [unowned self] (note) -> Void in
      self.reloadSong()
    }
    
    if (nowPlaying.isPlaying) {
      playButton.setImage(UIImage(named: "pause_button"), forState: UIControlState.Normal)
    } else {
      playButton.setImage(UIImage(named: "play_button"), forState: UIControlState.Normal)
    }
  }

  deinit {
    if let actualListener = listener {
      let center = NSNotificationCenter.defaultCenter()
      center.removeObserver(actualListener)
    }
  }

  override var song: Song? {
    set {
    }
    get {
      return nowPlaying.queue.current?.song
    }
  }

  @IBAction func pressedPlayButton(sender: UIButton) {
    if (nowPlaying.isPlaying) {
      nowPlaying.pause()
      sender.setImage(UIImage(named: "play_button"), forState: UIControlState.Normal)
    } else {
      nowPlaying.play()
      sender.setImage(UIImage(named: "pause_button"), forState: UIControlState.Normal)
    }
  }

  @IBAction func pressedPreviousButton(sender: UIButton) {
    nowPlaying.last()
  }

  @IBAction func pressedNextButton(sender: UIButton) {
    nowPlaying.next()
  }

  @IBAction func changedScrubberValue(sender: AnyObject) {
    nowPlaying.scrub()
  }

}
