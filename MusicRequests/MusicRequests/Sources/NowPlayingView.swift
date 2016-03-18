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

  weak var delegate: NowPlayingViewDelegate?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    translatesAutoresizingMaskIntoConstraints = false
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    // set the color of the background
    backgroundColor = Style.dark
  }

  func updateContent(withQueueItem item: QueueItem?) {
    customTextLabel.text = item?.song.name
    customDetailTextLabel.text = item?.song.artistAlbumString
    customImageView.image = item?.song.album?.imageToShow
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
