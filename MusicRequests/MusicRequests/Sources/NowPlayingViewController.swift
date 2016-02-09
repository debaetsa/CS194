//
//  PlayerViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//
//

import UIKit

class NowPlayingViewController: SongViewController {

  let nowPlaying = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.nowPlaying)!
  var listener: NSObjectProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()

    let center = NSNotificationCenter.defaultCenter()
    listener = center.addObserverForName(Queue.didChangeNowPlayingNotification, object: nowPlaying.queue, queue: nil) { [unowned self] (note) -> Void in
      self.reloadSong()
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
    nowPlaying.play()
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
