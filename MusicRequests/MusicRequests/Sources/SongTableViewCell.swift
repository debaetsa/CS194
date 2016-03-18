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

//      var imageView: UIImageView?
//      let vote = song.cachedVote
    //
      //imageView = UIImageView(frame: CGRectMake(0, 0, 28.0, 28.0))
//      if (vote == .Up) {
//        imageView!.image = UIImage(named: "up_vote")
//      } else if (vote == .Down) {
//        imageView!.image = UIImage(named: "down_vote")
//      } else {
//        imageView = nil
//      }
//      cell.accessoryView = imageView
}
