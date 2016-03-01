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

  /** We only want a nowPlaying object if it's one that we can modify. */
  let queue: Queue
  let maybeNowPlaying: LocalNowPlaying?

  var listener: NSObjectProtocol?

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    queue = AppDelegate.sharedDelegate.queue
    maybeNowPlaying = queue.nowPlaying as? LocalNowPlaying

    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    queue = AppDelegate.sharedDelegate.queue
    maybeNowPlaying = queue.nowPlaying as? LocalNowPlaying

    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let center = NSNotificationCenter.defaultCenter()
    listener = center.addObserverForName(Queue.didChangeNowPlayingNotification, object: queue, queue: nil) {
      [unowned self] (note) -> Void in
      self.reloadSong()
    }
    
    if (maybeNowPlaying != nil) && maybeNowPlaying!.isPlaying {
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
      return queue.current?.song
    }
  }

  @IBAction func pressedPlayButton(sender: UIButton) {
    if let nowPlaying = maybeNowPlaying {
      if (nowPlaying.isPlaying) {
        nowPlaying.pause()
        sender.setImage(UIImage(named: "play_button"), forState: UIControlState.Normal)
      } else {
        nowPlaying.play()
        sender.setImage(UIImage(named: "pause_button"), forState: UIControlState.Normal)
      }
    }
  }

  @IBAction func pressedPreviousButton(sender: UIButton) {
    if let nowPlaying = maybeNowPlaying {
      nowPlaying.last()
    }
  }

  @IBAction func pressedNextButton(sender: UIButton) {
    if let nowPlaying = maybeNowPlaying {
      nowPlaying.next()
    }
  }

  @IBAction func changedScrubberValue(sender: AnyObject) {
  }

}
