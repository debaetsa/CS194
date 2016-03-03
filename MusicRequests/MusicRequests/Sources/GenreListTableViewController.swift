//
//  GenresTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/18/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class GenreListTableViewController: ItemListTableViewController {

  var items: [Genre]!

  override func viewDidLoad() {
    super.viewDidLoad()

    if items == nil {
      items = library.allGenres
    }
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let genre = items[indexPath.row]

    cell.textLabel?.text = genre.name
    cell.detailTextLabel?.text = genre.allSongs.count.pluralize(("Song", "Songs"))

    return cell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushSongList" {
    }
  }

}
