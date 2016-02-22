//
//  GenresTableViewController.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/18/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class GenresTableViewController: ItemTableViewController {

  var genre: Genre?

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allGenres.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let genres = library.allGenres
    let currentGenre = genres[indexPath.row]

    cell.textLabel?.text = currentGenre.name
    cell.detailTextLabel?.text = "\(currentGenre.allSongs.count.pluralize(("Song", "Songs")))"

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    genre = library.allGenres[indexPath.row]
    performSegueWithIdentifier("ToGenreDetail", sender: self)
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if (segue.identifier == "ToGenreDetail") {
      // Create a new variable to store the instance of PreviewController
      let destinationVC = segue.destinationViewController as! DetailedGenreTableViewController
      destinationVC.genre = genre
    }
  }

}
