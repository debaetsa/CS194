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
  @IBOutlet weak var scrubber: UISlider!
  @IBOutlet weak var startLabel: UILabel!
  @IBOutlet weak var endLabel: UILabel!

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
    
    scrubber.minimumValue = 0.0
    scrubber.maximumValue = 10.0
    scrubber.value = 0.0
    endLabel.text = ""
    startLabel.text = ""
    
    _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)

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
  
  @IBAction func changedScrubberValue(sender: UISlider) {
    if (maybeNowPlaying != nil) {
      maybeNowPlaying!.scrub(Double(scrubber.value))
    }
  }
  
  func updateTime(){
    if (maybeNowPlaying != nil && maybeNowPlaying?.isPlaying == true){
      let endTime = (maybeNowPlaying?.currentPlayBackDuration())!
      let startTime = (maybeNowPlaying?.currentPlayBackTime())!
      scrubber.minimumValue = 0.0
      scrubber.maximumValue = Float(endTime)
      scrubber.value = Float(startTime)
    
      var endMinutes = String(Int(endTime/60))
      if endMinutes.isEmpty {
        endMinutes = "0"
      }
      
      var endSeconds = String(Int(endTime%60))
      if endSeconds.isEmpty {
        endSeconds = "00"
      } else if endSeconds.characters.count == 1 {
        endSeconds = "0" + String(Int(endTime%60))
      }
      
      var startMinutes = String(Int(startTime/60))
      if startMinutes.isEmpty {
        startMinutes = "0"
      }
      
      var startSeconds = String(Int(startTime%60))
      if startSeconds.isEmpty {
        startSeconds = "00"
      } else if startSeconds.characters.count == 1 {
        startSeconds = "0" + String(Int(startTime%60))
      }
      
      let endTimeString = endMinutes + ":" + endSeconds
      let startTimeString = startMinutes + ":" + startSeconds;
    
      endLabel.text = endTimeString
      startLabel.text = startTimeString
    }
  }
}
