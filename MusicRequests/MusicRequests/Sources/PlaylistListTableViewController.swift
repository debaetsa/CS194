//
//  PlaylistsTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/17/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class PlaylistListTableViewController: ItemListTableViewController {

  var items: [Playlist]!

  override func viewDidLoad() {
    super.viewDidLoad()

    // If we get to this point and don't have any data to show, we want to use
    // the default list of all playlists.
    if items == nil {
      items = library.allPlaylists
    }
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let playlist = items[indexPath.row]

    cell.textLabel?.text = playlist.name
    cell.detailTextLabel?.text = playlist.allSongs.count.pluralize(("Song", "Songs"))

    return cell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushSongList" {
      let destination = segue.destinationViewController as! SongListTableViewController
      let playlist = items[indexPathForSender(sender).row]
      destination.setSongList(playlist.allSongs, addTrackNumbers: true)
    }
  }
}