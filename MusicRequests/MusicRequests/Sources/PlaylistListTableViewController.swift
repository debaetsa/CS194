//
//  PlaylistsTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/17/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class PlaylistListTableViewController: ItemListTableViewController {

  var maybeItems: [Playlist]?

  override func viewDidLoad() {
    if let _ = maybeItems {
      containsFilteredItems = true  // set this before loading
    }

    super.viewDidLoad()
  }

  override func reloadItems() {
    super.reloadItems()

    maybeItems = loadedLibrary?.allPlaylists
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return maybeItems?.count ?? 1
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    if let items = maybeItems {
      let playlist = items[indexPath.row]
      cell.textLabel?.text = playlist.name
      cell.detailTextLabel?.text = playlist.allSongs.count.pluralize(("Song", "Songs"))
      cell.selectionStyle = .Default

    } else {
      cell.textLabel?.text = "Loading…"
      cell.selectionStyle = .None
    }

    return cell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushSongList", let items = maybeItems {
      let destination = segue.destinationViewController as! SongListTableViewController
      let playlist = items[indexPathForSender(sender).row]
      destination.setSongList(playlist.allSongs, addTrackNumbers: true)
    }
  }
}