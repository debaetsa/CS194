//
//  PlaylistSelectionTableViewController.swift
//  MusicRequests
//
//  Created by Max Radermacher on 3/16/16.
//
//

import UIKit

class PlaylistSelectionTableViewController: UITableViewController {

  // get the Session where these properties apply
  let localSession: LocalSession
  let fullLibrary: Library

  var initialSelection: Int?  // set to the start value to avoid unnecessry changes
  var nextSelection: Int? {  // set when the view is going to disappear
    didSet {
      var playlist: Playlist? = nil
      if let selection = nextSelection {
        playlist = fullLibrary.allPlaylists[selection]
      }
      logger("chose new playlist: \(playlist?.name)")
    }
  }

  required init?(coder aDecoder: NSCoder) {
    localSession = AppDelegate.sharedDelegate.localSession
    fullLibrary = localSession.fullLibrary

    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let maybePlaylist = (localSession.sourceLibrary as? FilteredLibrary)?.playlist
    if let playlist = maybePlaylist {
      initialSelection = fullLibrary.allPlaylists.indexOf(playlist)
    } else {
      initialSelection = nil
    }
    nextSelection = initialSelection
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    // update the sourceLibrary of localSession

    if initialSelection != nextSelection {
      if let nextPlaylistIndex = nextSelection {
        localSession.sourceLibrary = FilteredLibrary(playlist: fullLibrary.allPlaylists[nextPlaylistIndex])
      } else {
        localSession.sourceLibrary = fullLibrary  // selected "All Music"
      }
    }
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fullLibrary.allPlaylists.count + 1
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistCell", forIndexPath: indexPath)

    if indexPath.row == 0 {
      cell.textLabel?.text = "All Music"
      cell.accessoryType = (nextSelection == nil) ? .Checkmark : .None

    } else {
      let playlist = fullLibrary.allPlaylists[indexPath.row - 1]
      cell.textLabel?.text = playlist.name
      cell.accessoryType = (nextSelection == (indexPath.row - 1)) ? .Checkmark : .None
    }

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // Deselect the current row (if it is visible).  If it is not visible, then
    // it will be properly configured the next time it appears.
    let currentIndex = 1 + (nextSelection ?? -1)
    if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0)) {
      cell.accessoryType = .None  // clear the selection
    }

    if indexPath.row == 0 {
      nextSelection = nil
    } else {
      nextSelection = indexPath.row - 1
    }

    // Select the new Playlist.
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      cell.accessoryType = .Checkmark
    }

    // And then deselect the row.
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}
