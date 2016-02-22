//
//  DetailedPlaylistTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/18/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class DetailedPlaylistTableViewController: ItemTableViewController {

  var song: Song?
  var playlist: Playlist?
  @IBOutlet weak var NavBar: UINavigationItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    NavBar.title = playlist!.name
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return playlist!.allSongs.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let song = playlist!.allSongs[indexPath.row]
    cell.textLabel?.text = song.name
    cell.detailTextLabel?.text = song.artistAlbumString
    cell.imageView?.image = song.album?.imageToShow

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    song = playlist!.allSongs[indexPath.row]
    performSegueWithIdentifier("ToSongPreview", sender: self)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "ToSongPreview" {
      // we need to cast the destination controller; it's a bad error if we can't
      let destination = segue.destinationViewController as! SongViewController

      // set the data to show
      destination.song = song
    }
  }

}
