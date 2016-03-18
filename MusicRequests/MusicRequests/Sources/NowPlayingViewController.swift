//
//  PlayerViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//
//

import UIKit

/** This class manages the play controls.

   It will add their functionality, update their state, and show/hide them as
   needed.  It is used on this view controller and on the cell that shows the
   currently-playing song in the queue. */
class PlayControlsView: UIView {
  @IBOutlet weak var buttonPlayPause: UIButton!
  @IBOutlet weak var buttonNext: UIButton!
  @IBOutlet weak var buttonPrevoius: UIButton!

  private var nowPlayingListener: NSObjectProtocol?

  private var maybeNowPlaying: LocalNowPlaying? {
    didSet {
      // hide without "nowPlaying"
      hidden = (maybeNowPlaying == nil)

      // update the button state (it depends on this value)
      updatePlayPauseButton()

      // register for updates if the value changes elsewhere in the application
      let center = NSNotificationCenter.defaultCenter()
      if let listener = nowPlayingListener {
        center.removeObserver(listener)
      }
      if let nowPlaying = maybeNowPlaying {
        nowPlayingListener = center.addObserverForName(NowPlaying.didChangeNotification, object: nowPlaying, queue: nil) {
          [unowned self] (note) in self.updatePlayPauseButton()
        }
      }
    }
  }
  private var nowPlaying: LocalNowPlaying {
    // This is used when we are assuming that the content is visible.
    return maybeNowPlaying!
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    registerForNotifications()
    updatePlayPauseButton()
  }

  deinit {
    unregisterFromNotifications()

    let center = NSNotificationCenter.defaultCenter()
    if let listener = nowPlayingListener {
      center.removeObserver(listener)
    }
  }

  private func updatePlayPauseButton() {
    if maybeNowPlaying?.isPlaying == true {  // cool trick with Optionals…
      buttonPlayPause.setImage(UIImage(named: "pause_button"), forState: UIControlState.Normal)
    } else {
      buttonPlayPause.setImage(UIImage(named: "play_button"), forState: UIControlState.Normal)
    }
  }

  @IBAction func pressedPlayButton(sender: UIButton) {
    if nowPlaying.isPlaying {
      nowPlaying.pause()
    } else {
      nowPlaying.play()
    }
  }

  @IBAction func pressedPreviousButton(sender: UIButton) {
    nowPlaying.last()
  }

  @IBAction func pressedNextButton(sender: UIButton) {
    nowPlaying.next()
  }

  // MARK: - Session/Queue Change Notifications

  private var sessionChangedListener: NSObjectProtocol?
  private var queueChangedListener: NSObjectProtocol?

  private func registerForNotifications() {
    let center = NSNotificationCenter.defaultCenter()

    let didChangeSession = {
      [unowned self] (note: NSNotification?) in

      self.updateQueueListener()
    }
    sessionChangedListener = center.addObserverForName(
      AppDelegate.didChangeSession, object: nil, queue: nil, usingBlock: didChangeSession
    )
    didChangeSession(nil)
  }

  private func updateQueueListener() {
    let center = NSNotificationCenter.defaultCenter()

    if let listener = queueChangedListener {
      center.removeObserver(listener)
    }

    let didChangeQueue = {
      [unowned self] (note: NSNotification?) in

      // Set this if it is of the proper type to show the buttons.  If it's
      // not, then it will remain invisible.
      self.maybeNowPlaying = (AppDelegate.sharedDelegate.currentSession.queue?.nowPlaying as? LocalNowPlaying)
    }
    queueChangedListener = center.addObserverForName(Session.didChangeQueueNotification,
      object: AppDelegate.sharedDelegate.currentSession, queue: nil, usingBlock: didChangeQueue
    )
    didChangeQueue(nil)
  }

  private func unregisterFromNotifications() {
    let center = NSNotificationCenter.defaultCenter()
    if let listener = sessionChangedListener {
      center.removeObserver(listener)
    }
    if let listener = queueChangedListener {
      center.removeObserver(listener)
    }
  }
}


class NowPlayingViewController: SongViewController {

  @IBOutlet weak var viewScrubber: UIView!
  @IBOutlet weak var scrubber: UISlider!
  @IBOutlet weak var startLabel: UILabel!
  @IBOutlet weak var endLabel: UILabel!

  private var maybeQueue: Queue?
  private var nowPlayingUpdatedListener: NSObjectProtocol?
  private var maybeNowPlaying: LocalNowPlaying?  // only need local for this

  override func viewDidLoad() {
    maybeQueue = AppDelegate.sharedDelegate.currentSession.queue

    let updateCurrentSong = { [unowned self] in
      self.song = self.maybeQueue?.current?.song  // set it if we can
    }
    updateCurrentSong()

    super.viewDidLoad()

    // register for updates when the current song changes
    if let queue = maybeQueue {
      let center = NSNotificationCenter.defaultCenter()
      nowPlayingUpdatedListener = center.addObserverForName(Queue.didChangeNowPlayingNotification, object: queue, queue: nil) {
        [unowned self] (note) -> Void in

        updateCurrentSong()
        self.reloadSong()
      }

      // get a reference to this, but only if it's modifiable
      maybeNowPlaying = (queue.nowPlaying as? LocalNowPlaying)

    }

    // We are running on the local device, so get everything configured.
    if let _ = maybeNowPlaying {
      scheduleScrubberUpdate()
      updateScrubberDetails()

    } else {
      viewScrubber.hidden = true  // make it invisible
    }

    // set this font in code -- it's not accessible in Interface Builder
    startLabel.font = UIFont.monospacedDigitSystemFontOfSize(14, weight: UIFontWeightRegular)
    endLabel.font = UIFont.monospacedDigitSystemFontOfSize(14, weight: UIFontWeightRegular)
  }

  deinit {
    let center = NSNotificationCenter.defaultCenter()
    if let listener = nowPlayingUpdatedListener {
      center.removeObserver(listener)
    }
  }

  override func reloadSong() {
    super.reloadSong()

    // We need to size the headerView as appropriate.  We will set it to the
    // ideal size, and then we'll let the navigationItem resize it as needed.
    var idealWidth: CGFloat = 0

    // Figure out the space needed for each label.
    idealWidth = max(idealWidth, labelSongName.intrinsicContentSize().width)
    idealWidth = max(idealWidth, labelSongArtist!.intrinsicContentSize().width)

    // Then set the bounds to that value.
    var bounds = navigationItem.titleView!.bounds
    bounds.size.width = idealWidth
    navigationItem.titleView!.bounds = bounds
  }

  @IBAction func changedScrubberValue(sender: UISlider) {
    if (maybeNowPlaying != nil) {
      maybeNowPlaying!.scrub(Double(scrubber.value))
    }
  }

  private func scheduleScrubberUpdate() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
      [weak self] in

      // If "self" goes away, then this won't get called, and we won't schedule
      // the block to run again.  If it's still here, then it will run.
      //
      // This breaks the retain cycle that was present with the timer approach.
      self?.updateScrubberDetails()
      self?.scheduleScrubberUpdate()
    }
  }

  private func formatTime(maybeValue: NSTimeInterval?) -> String {
    if let value = maybeValue {
      if !value.isNaN {
        let roundedValue = Int(floor(value))
        let minutes = roundedValue / 60
        let seconds = roundedValue % 60

        return String(format: "%d:%02d", minutes, seconds)
      }
    }
    return "0:00"  // use this as the value when an error occurs
  }

  private func updateScrubberDetails() {
    let current = maybeNowPlaying!.currentPlaybackTime
    let total = maybeNowPlaying!.currentPlaybackDuration

    scrubber.value = Float(current ?? 0)
    scrubber.maximumValue = Float(total ?? 1)  // use "1" to avoid divide by zero

    startLabel.text = formatTime(current)
    endLabel.text = formatTime(total)
  }
}
