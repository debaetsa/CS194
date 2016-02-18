//
//  DetailedPlaylistTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/18/16.
//
//

import UIKit

class DetailedPlaylistTableViewController: ItemTableViewController {

  var playlist: Playlist?
  var playlistName: String?
  @IBOutlet weak var NavBar: UINavigationItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    NavBar.title = playlistName
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

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "preview" {
      // find the NSIndexPath, crashing if we are unable to find it
      let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!

      // we need to cast the destination controller; it's a bad error if we can't
      let destination = segue.destinationViewController as! SongViewController

      // set the data to show
      destination.song = playlist!.allSongs[indexPath.row]
    }
  }

}
