//
//  PreviewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//
//

import UIKit

class SongViewController: UIViewController {

  // the screen we came from
  var previousScreen: String?

  // set the outlets for updating the information
  @IBOutlet weak var labelSongName: UILabel!
  @IBOutlet weak var labelSongDetails: UILabel!
  @IBOutlet weak var imageViewAlbumArt: UIImageView!

  // the Song that we are supposed to display
  var song: Song?

  override func viewDidLoad() {
    super.viewDidLoad()

    let edgePanRecognizer = UIScreenEdgePanGestureRecognizer()
    edgePanRecognizer.addTarget(self, action: "edgePanned:")
    edgePanRecognizer.edges = .Left
    view.addGestureRecognizer(edgePanRecognizer)

    reloadSong()
  }

  func reloadSong() {
    labelSongName.text = song?.name
    labelSongDetails.text = song?.artistAlbumString
    imageViewAlbumArt.image = song?.album?.imageToShow
  }

  func edgePanned(sender: UIScreenEdgePanGestureRecognizer) {
    performSegueWithIdentifier("unwindToPrevious", sender: self)
  }

}
