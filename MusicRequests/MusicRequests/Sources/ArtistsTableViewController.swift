//
//  ArtistsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ArtistsTableViewController: ItemTableViewController {


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
    cell.imageView?.image = UIImage(named: "hozier_album.png")!


    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let clickedOnArtist = library.allArtists[indexPath.row]
    songTitle = clickedOnArtist.name
    artistName = clickedOnArtist.artists.map({ $0.name }).joinWithSeparator(", ")
    albumName = clickedOnArtist.album!.name
    
    performSegueWithIdentifier("ToPreview", sender: self)
  }
}
