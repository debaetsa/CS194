//
//  DetailedAlbumTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/8/16.
//
//

import UIKit

class DetailedAlbumTableViewController: ItemTableViewController {

  var items: [Track]!
  var album: Album?

  override func viewDidLoad() {
    super.viewDidLoad()

    // cache the list of items that we are going to show
    items = album?.songs
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let song = items[indexPath.row].song
    cell.textLabel?.text = song.name
    cell.detailTextLabel?.text = song.artistAlbumString
    cell.imageView?.image = album?.imageToShow

    return cell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "preview" {
      // find the NSIndexPath, crashing if we are unable to find it
      let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!

      // we need to cast the destination controller; it's a bad error if we can't
      let destination = segue.destinationViewController as! SongViewController

      // set the data to show
      destination.song = items[indexPath.row].song
    }
  }
}
