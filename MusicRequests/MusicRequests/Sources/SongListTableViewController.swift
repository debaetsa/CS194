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
        return "DetailedNumbered"
      } else {
        return "BasicNumbered"
      }
    } else {
      return "Basic"
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
      // Use "!" here since we require a class of a particular type for this to work.
      let cell = tableView.dequeueReusableCellWithIdentifier(getCellIdentifier(), forIndexPath: indexPath) as! SongTableViewCell

      // Get the number/song to be displayed in this row.
      let (number, song) = numberedItems[indexPath.row]

      cell.delegate = self
      cell.updateContent(withSong: song, andNumber: number)
      cell.selectionStyle = .Default

      return cell

    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("Loading", forIndexPath: indexPath)

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

extension SongListTableViewController: SwipeTableViewCellDelegate {
  func swipeTableViewCell(cell: SwipeTableViewCell, didPressButton button: SwipeTableViewCell.Direction) {
    if let numberedItems = maybeNumberedItems, let indexPath = tableView.indexPathForCell(cell) {

      // get the Song for the swiped row
      let (number, song) = numberedItems[indexPath.row]

      if let remoteQueue = AppDelegate.sharedDelegate.currentSession.queue as? RemoteQueue {
        // We have a valid RemoteQueue object.  Log an error if we don't.
        switch button {
        case .Right:
          remoteQueue.upvote(withSong: song)

        case .Left:
          remoteQueue.downvote(withSong: song)
        }

      } else {
        logger("could not handle swipe")
      }

      // Refresh the display to immediately indicate the vote.  This avoids
      // needing to reload the entire table view.
      (cell as! SongTableViewCell).updateContent(withSong: song, andNumber: number)

    } else {
      logger("could not find indexPath of cell")
    }
  }
}
