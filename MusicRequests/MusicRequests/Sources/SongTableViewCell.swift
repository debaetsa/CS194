//
//  SongTableViewCell.swift
//  MusicRequests
//
//  Created by Max Radermacher on 3/17/16.
//
//

import UIKit

class SongTableViewCell: SwipeTableViewCell {
  // The "!" references are required.  The "?" values are optional, and the
  // cell will simply skip filling them out if they are not set.
  @IBOutlet weak var customTextLabel: UILabel!
  @IBOutlet weak var customDetailTextLabel: UILabel?
  @IBOutlet weak var customNumberLabel: UILabel?
  @IBOutlet weak var customImageView: UIImageView?
  @IBOutlet weak var customIndicatorImageView: UIImageView?

  // Updates the fields of this cell based on the specified Song.
  func updateContent(withSong song: Song, andNumber maybeNumber: Int? = nil) {
    customTextLabel.text = song.name
    customDetailTextLabel?.text = song.artistAlbumString
    customImageView?.image = song.album?.imageToShow  // TODO: might not get an image

    customNumberLabel?.textColor = Style.gray

    if let number = maybeNumber {
      customNumberLabel?.text = "\(number)."
    } else {
      customNumberLabel?.text = nil
    }

    if let indicatorImageView = customIndicatorImageView {
      // We need to provide SOME value for this as there is a reference.  We'll
      // use "None" if it is not a LocalQueueItem
      switch song.cachedVote {
      case .Up:
        indicatorImageView.image = UIImage(named: "up_vote")

      case .Down:
        indicatorImageView.image = UIImage(named: "down_vote")

      case .None:
        indicatorImageView.image = nil  // don't show an image if there isn't a vote
      }
    }
  }

}
