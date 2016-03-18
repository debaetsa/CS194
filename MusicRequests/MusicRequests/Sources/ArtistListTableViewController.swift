//
//  ArtistsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ArtistListTableViewController: ItemListTableViewController {
  var maybeItems: [Artist]?

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return maybeItems?.count ?? 1
  }

  override func viewDidLoad() {
    if let _ = maybeItems {
      containsFilteredItems = true
    }

    super.viewDidLoad()
  }

  override func reloadItems() {
    super.reloadItems()

    maybeItems = loadedLibrary?.allArtists
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {


    if let items = maybeItems {
      let cell = self.tableView.dequeueReusableCellWithIdentifier("Standard", forIndexPath: indexPath) as! StandardTableViewCell

      let artist = items[indexPath.row]
      let albums = artist.allAlbums
      let countOfAlbums = albums.count
      let countOfSongs = albums.reduce(0) { $0 + $1.songs.count }

      cell.customTextLabel.text = artist.name
      cell.customDetailTextLabel.text = "\(countOfAlbums.pluralize(("Album", "Albums"))) • \(countOfSongs.pluralize(("Song", "Songs")))"
      cell.customImageView.image = artist.allAlbums.first?.imageToShow
      cell.selectionStyle = .Default

      return cell

    } else {
      let cell = self.tableView.dequeueReusableCellWithIdentifier("Loading", forIndexPath: indexPath)
      cell.textLabel?.text = "Loading…"
      cell.selectionStyle = .None
      return cell
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushAlbumList", let items = maybeItems {
      let destination = segue.destinationViewController as! AlbumListTableViewController
      let indexPath = indexPathForSender(sender)
      let artist = items[indexPath.row]
      destination.navigationItem.title = artist.name
      destination.maybeItems = artist.allAlbums
    }
  }
}
