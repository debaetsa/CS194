//
//  PlaylistsTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/17/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class PlaylistsTableViewController: ItemTableViewController {

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allPlaylists.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let playlists = library.allPlaylists
    let currentPlaylist = playlists[indexPath.row]

    cell.textLabel?.text = currentPlaylist.name
    //cell.detailTextLabel?.text = currentPlaylist.artistAlbumString
    //cell.imageView?.image = currentPlaylist.album!.imageToShow

    return cell
  }

  //  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
  //    if segue.identifier == "preview" {
  //      let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
  //      let destination = segue.destinationViewController as! SongViewController
  //      destination.song = library.allSongs[indexPath.row]
  //    }
  //  }

}