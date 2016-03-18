//
//  SongsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongListTableViewController: ItemListTableViewController {

  var maybeFilteredItems: [(Int?, Song)]?
  var maybeNumberedItems: [(Int?, Song)]?
  var showNumbers = false
  var showDetails = true

  // the controller for the search -- only visible for "All Songs"
  private var searchController: UISearchController?

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController?.active == true {
      return maybeFilteredItems?.count ?? 0  // don't show "Loading…" in search
    } else {
      return maybeNumberedItems?.count ?? 1
    }
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

    // We want to show the Search UI only when in the list of Songs.
    if !containsFilteredItems {
      let controller = UISearchController(searchResultsController: nil)
      controller.delegate = self
      controller.searchResultsUpdater = self
      controller.dimsBackgroundDuringPresentation = false
      tableView.tableHeaderView = controller.searchBar
      definesPresentationContext = true
      searchController = controller
    }
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
      let number: Int?; let song: Song
      if let filteredItems = maybeFilteredItems where searchController?.active == true {
        (number, song) = filteredItems[indexPath.row]
      } else {
        (number, song) = numberedItems[indexPath.row]
      }

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

      let song: Song
      if let filteredItems = maybeFilteredItems where searchController?.active == true {
        (_, song) = filteredItems[indexPath.row]
      } else {
        (_, song) = numberedItems[indexPath.row]
      }
      destination.song = song
    }
  }
}

extension SongListTableViewController: SwipeTableViewCellDelegate {
  func swipeTableViewCell(cell: SwipeTableViewCell, didPressButton button: SwipeTableViewCell.Direction) {
    if let numberedItems = maybeNumberedItems, let indexPath = tableView.indexPathForCell(cell) {

      // get the Song for the swiped row
      let number: Int?; let song: Song
      if let filteredItems = maybeFilteredItems where searchController?.active == true {
        (number, song) = filteredItems[indexPath.row]
      } else {
        (number, song) = numberedItems[indexPath.row]
      }

      if let remoteQueue = AppDelegate.sharedDelegate.currentSession.queue as? RemoteQueue {
        // We have a valid RemoteQueue object.  Log an error if we don't.
        switch button {
        case .Right:
          remoteQueue.upvote(withSong: song)

        case .Left:
          remoteQueue.downvote(withSong: song)
        }

      }

      if let localQueue = AppDelegate.sharedDelegate.currentSession.queue as? LocalQueue {
        localQueue.applyVote((button == .Right) ? .Up : .Down, toSong: song)
      }

      // Refresh the display to immediately indicate the vote.  This avoids
      // needing to reload the entire table view.
      (cell as! SongTableViewCell).updateContent(withSong: song, andNumber: number)

    } else {
      logger("could not find indexPath of cell")
    }
  }
}

extension SongListTableViewController: UISearchControllerDelegate {
  func willPresentSearchController(searchController: UISearchController) {
  }
  func didDismissSearchController(searchController: UISearchController) {
  }
}

extension SongListTableViewController: UISearchResultsUpdating {
  private func filterWithString(maybeString: String?) {
    if let string = maybeString {
      let terms = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter {
        $0.characters.count > 0
      }
      maybeFilteredItems = maybeNumberedItems?.filter { item in
        for term in terms {
          if !item.1.name.localizedCaseInsensitiveContainsString(term) {
            return false
          }
        }
        return true
      }

    } else {
      maybeFilteredItems = nil
    }

    tableView.reloadData()
  }

  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterWithString(searchController.searchBar.text)
  }
}
