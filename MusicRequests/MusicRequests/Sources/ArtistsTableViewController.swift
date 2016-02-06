//
//  ArtistsTableViewController.swift
//  appName
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ArtistsTableViewController: MyTableViewController {
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allArtists.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let artists = library.allArtists
    let images = ["killers_album.png", "the_postal_service_album.png", "the_family_crest_album.png", "hozier_album.png", "sf_symphony_album.png"]
    
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    let currentArtist = artists[indexPath.row]
    
    cell.textLabel?.text = "\(currentArtist.name)"

    let albumCount = currentArtist.albums.count
    var albumSuffix = "albums"
    if (albumCount == 1) {
      albumSuffix = "album"
    }

    var songCount = 0
    for album in currentArtist.albums {
      songCount += album.songs.count
    }
    
    var songSuffix = "songs"
    if (songCount == 1) {
      songSuffix = "song"
    }

    cell.detailTextLabel?.text = "\(albumCount) \(albumSuffix) - \(songCount) \(songSuffix)"
    cell.imageView?.image = UIImage(named: images[indexPath.row % images.count])!
    return cell
    
  }
}
