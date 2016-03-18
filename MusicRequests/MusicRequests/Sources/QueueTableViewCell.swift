//
//  QueueTableViewCell.swift
//  MusicRequests
//
//  Created by Max Radermacher on 3/17/16.
//
//

import UIKit

class QueueTableViewCell: SwipeTableViewCell {
  @IBOutlet weak var customTextLabel: UILabel!
  @IBOutlet weak var customDetailTextLabel: UILabel!
  @IBOutlet weak var customImageView: UIImageView!
  @IBOutlet weak var customIndicatorImageView: UIImageView!

  func updateContent(withQueueItem item: QueueItem) {
    customTextLabel.text = item.song.name
    customDetailTextLabel.text = item.song.artistAlbumString
    customImageView.image = item.song.album?.imageToShow

    if let indicatorImageView = customIndicatorImageView {
      // We need to provide SOME value for this as there is a reference.  We'll
      // use "None" if it is not a LocalQueueItem
      switch (item as? RemoteQueueItem)?.request.vote ?? .None {
      case .Up:
        indicatorImageView.image = UIImage(named: "Temp_up_button")

      case .Down:
        indicatorImageView.image = UIImage(named: "Temp_down_button")

      case .None:
        indicatorImageView.image = nil  // don't show an image if there isn't a vote
      }
    }
  }
}
