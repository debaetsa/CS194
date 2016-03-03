//
//  SongsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongListTableViewController: ItemListTableViewController {

  var numberedItems: [(Int?, Song)]!
  var showNumbers = false
  var showDetails = true

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberedItems.count
  }

  func setSongList(songs: [Song], addTrackNumbers: Bool = false) {
    numberedItems = songs.map { (nil, $0) }
    if addTrackNumbers {
      for index in 0..<numberedItems.count {
        numberedItems[index].0 = (index + 1)
      }
    }
    showNumbers = addTrackNumbers
  }

  func setTrackList(tracks: [Track]) {
    numberedItems = tracks.map { ($0.track, $0.song) }
    showNumbers = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if numberedItems == nil {
      setSongList(library.allSongs)
    }
  }

  private func getCellIdentifier() -> String {
    if showNumbers {
      if showDetails {
        return "DetailedNumberedCell"
      } else {
        return "BasicNumberedCell"
      }
    } else {
      return "SmallCell"
    }
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if showNumbers && !showDetails {
      return 40
    } else {
      return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(getCellIdentifier(), forIndexPath: indexPath)

    let (number, song) = numberedItems[indexPath.row]

    if showNumbers {
      (cell as! NumberedTableViewCell).numberedItem = (number!, song)
    } else {
      cell.textLabel?.text = song.name
      cell.detailTextLabel?.text = song.artistAlbumString
      cell.imageView?.image = song.album!.imageToShow
    }

    return cell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushSongPreview" {
      let destination = segue.destinationViewController as! SongViewController
      let indexPath = indexPathForSender(sender)

      let (_, song) = numberedItems[indexPath.row]
      destination.song = song
    }
  }
}

class NumberedTableViewCell : UITableViewCell {
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var labelDetails: UILabel?
  @IBOutlet weak var labelNumber: UILabel!

  var numberedItem: (number: Int, song: Song)? {
    didSet {
      if let item = numberedItem {
        labelName.text = item.song.name
        labelDetails?.text = item.song.artistAlbumString  // don't set if not needed
        labelNumber.text = "\(item.number)."
      }
    }
  }
}

