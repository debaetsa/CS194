//
//  ArtistsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ArtistsTableViewController: ItemTableViewController {
  var album: Album?
  var artist: Artist?
  var song: Song?
  var artistName: String?
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allArtists.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let artists = library.allArtists
    let currentArtist = artists[indexPath.row]
    let albums = currentArtist.allAlbums
    let albumCount = albums.count
    let songCount = albums.reduce(0) { $0 + $1.songs.count }

    // currentArtist.name is a String, so it doesn't need to be wrapped in
    // "\()" unless something else is being added to it.  It's redundant.
    cell.textLabel?.text = currentArtist.name
    cell.detailTextLabel?.text = "\(albumCount.pluralize(("Album", "Albums"))) • \(songCount.pluralize(("Song", "Songs")))"
    cell.imageView?.image = currentArtist.allAlbums[0].imageToShow

    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    artist = library.allArtists[indexPath.row]
    artistName = artist!.name
    performSegueWithIdentifier("ToArtistDetail", sender: self)
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if (segue.identifier == "ToArtistDetail") {
      // Create a new variable to store the instance of PreviewController
      let destinationVC = segue.destinationViewController as! DetailedArtistTableViewController
      destinationVC.artist = artist
      destinationVC.artistName = artistName
    }
  }
}
