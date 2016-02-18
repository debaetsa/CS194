//
//  GenresTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/18/16.
//
//

import UIKit

class GenresTableViewController: ItemTableViewController {

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allGenres.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let genres = library.allGenres
    let currentGenre = genres[indexPath.row]

    cell.textLabel?.text = currentGenre.name
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
