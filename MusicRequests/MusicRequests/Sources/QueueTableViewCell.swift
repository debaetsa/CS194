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

  func updateContent(withQueueItem item: QueueItem) {
    let prefix: String
    if let localQueueItem = item as? LocalQueueItem {
      prefix = "[\(localQueueItem.votes) Vote(s)] "

    } else if let remoteQueueItem = item as? RemoteQueueItem {
      prefix = "[\(remoteQueueItem.request.vote)] "

    } else {
      prefix = ""
    }

    customTextLabel.text = "\(prefix)\(item.song.name)"
    customDetailTextLabel.text = item.song.artistAlbumString
    customImageView.image = item.song.album?.imageToShow
  }
}
