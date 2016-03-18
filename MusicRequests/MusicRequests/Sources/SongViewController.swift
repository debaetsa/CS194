//
//  PreviewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongViewController: UIViewController {

  // set the outlets for updating the information
  @IBOutlet weak var labelSongName: UILabel!
  @IBOutlet weak var labelSongDetails: UILabel?
  @IBOutlet weak var labelSongArtist: UILabel?
  @IBOutlet weak var imageViewAlbumArt: UIImageView!

  // the Song that we are supposed to display
  var song: Song!

  override func viewDidLoad() {
    super.viewDidLoad()

    reloadSong()
  }

  func reloadSong() {
    navigationItem.title = song.name

    labelSongName.text = song.name
    if let label = labelSongDetails {
      label.text = song.artistAlbumString
    }
    if let label = labelSongArtist {
      label.text = song.artist?.name
    }
    imageViewAlbumArt.image = song.album?.imageToShow
  }

}
