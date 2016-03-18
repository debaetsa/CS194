//
//  GenresTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/18/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class GenreListTableViewController: ItemListTableViewController {

  var maybeItems: [Genre]?

  override func viewDidLoad() {
    if let _ = maybeItems {
      containsFilteredItems = true
    }

    super.viewDidLoad()
  }

  override func reloadItems() {
    super.reloadItems()

    maybeItems = loadedLibrary?.allGenres
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return maybeItems?.count ?? 1
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    if let items = maybeItems {
      let genre = items[indexPath.row]

      cell.textLabel?.text = genre.name
      cell.detailTextLabel?.text = genre.allSongs.count.pluralize(("Song", "Songs"))
      cell.selectionStyle = .Default

    } else {
      cell.textLabel?.text = "Loading…"
      cell.selectionStyle = .None
    }

    return cell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushSongList", let items = maybeItems {
      let destination = segue.destinationViewController as! SongListTableViewController
      let indexPath = indexPathForSender(sender)
      destination.setSongList(items[indexPath.row].allSongs)
    }
  }

}
