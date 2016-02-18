//
//  DetailedGenreTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/18/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class DetailedGenreTableViewController: ItemTableViewController {

  var genre: Genre?
  var genreName: String?
  @IBOutlet weak var NavBar: UINavigationItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    NavBar.title = genreName
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return genre!.allSongs.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    let song = genre!.allSongs[indexPath.row]
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
      destination.song = genre!.allSongs[indexPath.row]
    }
  }

}
