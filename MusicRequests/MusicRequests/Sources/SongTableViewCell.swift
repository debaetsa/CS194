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

  // Updates the fields of this cell based on the specified Song.
  func updateContent(withSong song: Song, andNumber maybeNumber: Int? = nil) {
    customTextLabel.text = song.name
    customDetailTextLabel?.text = song.artistAlbumString
    customImageView?.image = song.album?.imageToShow  // TODO: might not get an image

    if let number = maybeNumber {
      customNumberLabel?.text = "\(number)."
    } else {
      customNumberLabel?.text = nil
    }
  }
}
