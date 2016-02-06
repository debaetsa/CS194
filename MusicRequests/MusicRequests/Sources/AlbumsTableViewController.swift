//
//  AlbumsTableViewController.swift
//  appName
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class AlbumsTableViewController: MyTableViewController {
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allAlbums.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let albums = library.allAlbums
    let images = ["killers_album.png", "the_postal_service_album.png", "the_family_crest_album.png", "hozier_album.png", "sf_symphony_album.png"]
    
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    let currentAlbum = albums[indexPath.row]
    
    cell.textLabel?.text = "\(currentAlbum.name)"
    
    let artistNames = currentAlbum.artists.map{String($0.name)}.joinWithSeparator(", ")
    
    let songCount = currentAlbum.songs.count
    var suffix = "songs"
    if (songCount == 1) {
      suffix = "song"
    }
    
    cell.detailTextLabel?.text = "\(artistNames) - \(currentAlbum.songs.count) \(suffix)"
    cell.imageView?.image = UIImage(named: images[indexPath.row % images.count])!
    return cell
    
  }
}
