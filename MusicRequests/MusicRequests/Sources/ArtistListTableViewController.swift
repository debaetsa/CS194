//
//  ArtistsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ArtistListTableViewController: ItemListTableViewController {
  var items: [Artist]!

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if items == nil {
      items = library.allArtists
    }
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let artist = items[indexPath.row]
    let albums = artist.allAlbums
    let countOfAlbums = albums.count
    let countOfSongs = albums.reduce(0) { $0 + $1.songs.count }

    cell.textLabel?.text = artist.name
    cell.detailTextLabel?.text = "\(countOfAlbums.pluralize(("Album", "Albums"))) • \(countOfSongs.pluralize(("Song", "Songs")))"
    cell.imageView?.image = artist.allAlbums.first?.imageToShow

    return cell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushAlbumList" {
      let destination = segue.destinationViewController as! AlbumListTableViewController
      let indexPath = indexPathForSender(sender)
      let artist = items[indexPath.row]
      destination.navigationItem.title = artist.name
      destination.items = artist.allAlbums
    }
  }
}
