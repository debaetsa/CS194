//
//  SongsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongListTableViewController: ItemListTableViewController {

  var maybeNumberedItems: [(Int?, Song)]?
  var showNumbers = false
  var showDetails = true

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return maybeNumberedItems?.count ?? 1
  }

  func setSongList(songs: [Song], addTrackNumbers: Bool = false) {
    var numberedItems: [(Int?, Song)] = songs.map { (nil, $0) }
    if addTrackNumbers {
      for index in 0..<numberedItems.count {
        numberedItems[index].0 = (index + 1)
      }
    }
    maybeNumberedItems = numberedItems
    showNumbers = addTrackNumbers
  }

  func setTrackList(tracks: [Track]) {
    maybeNumberedItems = tracks.map { ($0.track, $0.song) }
    showNumbers = true
  }

  override func viewDidLoad() {
    if let _ = maybeNumberedItems {
      containsFilteredItems = true
    }

    super.viewDidLoad()
  }

  override func reloadItems() {
    super.reloadItems()

    if let songs = loadedLibrary?.allSongs {
      setSongList(songs)
    } else {
      maybeNumberedItems = nil
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

    if let numberedItems = maybeNumberedItems {
      let cell = tableView.dequeueReusableCellWithIdentifier(getCellIdentifier(), forIndexPath: indexPath)

      let (number, song) = numberedItems[indexPath.row]

      if showNumbers {
        (cell as! NumberedTableViewCell).numberedItem = (number!, song)
      } else {
        cell.textLabel?.text = song.name
        cell.detailTextLabel?.text = song.artistAlbumString
        cell.imageView?.image = song.album!.imageToShow
        cell.selectionStyle = .Default
      }

      return cell

    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

      cell.textLabel?.text = "Loading…"
      cell.selectionStyle = .None

      return cell
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushSongPreview", let numberedItems = maybeNumberedItems {
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

