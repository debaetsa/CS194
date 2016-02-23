//
//  PlaylistsTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/17/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class PlaylistsTableViewController: ItemTableViewController {
  var playlist: Playlist?

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allPlaylists.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let playlists = library.allPlaylists
    let currentPlaylist = playlists[indexPath.row]

    cell.textLabel?.text = currentPlaylist.name
    cell.detailTextLabel?.text = "\(currentPlaylist.allSongs.count.pluralize(("Song", "Songs")))"

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    playlist = library.allPlaylists[indexPath.row]
    performSegueWithIdentifier("ToPlaylistDetail", sender: self)
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if (segue.identifier == "ToPlaylistDetail") {
      // Create a new variable to store the instance of PreviewController
      let destinationVC = segue.destinationViewController as! DetailedPlaylistTableViewController
      destinationVC.playlist = playlist
    }
  }
}