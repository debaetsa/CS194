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
  var song: Song?
  var album: Album?
  @IBOutlet weak var NavBar: UINavigationItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    NavBar.title = album!.name
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

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    song = items[indexPath.row].song
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
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
      let upvote = UITableViewRowAction(style: .Normal, title: "+") { action, index in
      }
      upvote.backgroundColor = UIColor.blueColor()

      let downvote = UITableViewRowAction(style: .Normal, title: "-") { action, index in
      }
      downvote.backgroundColor = UIColor.redColor()

      return [downvote, upvote]
  }
}
