//
//  NowPlayingView.swift
//  MusicRequests
//
//  Created by Max Radermacher on 3/17/16.
//
//

import UIKit

protocol NowPlayingViewDelegate: class {
  func nowPlayingViewTapped(nowPlayingView: NowPlayingView)
}

class NowPlayingView: UIView {
  @IBOutlet weak var customTextLabel: UILabel!
  @IBOutlet weak var customDetailTextLabel: UILabel!
  @IBOutlet weak var customImageView: UIImageView!

  @IBOutlet weak var customButtonView: UIView!

  weak var delegate: NowPlayingViewDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    // set the color of the background
    backgroundColor = Style.dark

    // register for updates about the session
    listenForChanges()
  }

  deinit {
    let center = NSNotificationCenter.defaultCenter()
    if let listener = sessionChangedListener {
      center.removeObserver(listener)
    }
  }

  func updateContent(withQueueItem item: QueueItem?) {
    customTextLabel.text = item?.song.name
    customDetailTextLabel.text = item?.song.artistAlbumString
    customImageView.image = item?.song.album?.imageToShow
  }

  // MARK: - Button Visibility

  private var sessionChangedListener: NSObjectProtocol?
  private func listenForChanges() {
    let refreshVisibility = {
      [unowned self] (note: NSNotification?) in

      self.customButtonView.hidden = !(AppDelegate.sharedDelegate.currentSession is LocalSession)
    }

    // update the visibility whenever the Session is changed
    let center = NSNotificationCenter.defaultCenter()
    sessionChangedListener = center.addObserverForName(AppDelegate.didChangeSession, object: nil, queue: nil, usingBlock: refreshVisibility)
    refreshVisibility(nil)  // and right now for the initial state
  }

  // MARK: - Touch Handling

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
  }

  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    delegate?.nowPlayingViewTapped(self)
  }

  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
  }

  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
  }

}
