//
//  AlbumsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class AlbumsTableViewController: ItemTableViewController {


  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allAlbums.count
  }


  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let albums = library.allAlbums
    let currentAlbum = albums[indexPath.row]
    let artistNames = currentAlbum.artists.map({ $0.name }).joinWithSeparator(", ")
    let songCount = currentAlbum.songs.count

    cell.textLabel?.text = currentAlbum.name
    cell.detailTextLabel?.text = "\(artistNames) • \(songCount.pluralize(("Song", "Songs")))"
    cell.imageView?.image = currentAlbum.imageToShow

    return cell
  }
  
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    album = library.allAlbums[indexPath.row]
    performSegueWithIdentifier("ToAlbumDetail", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    
    if (segue.identifier == "ToAlbumDetail") {
      // Create a new variable to store the instance of PreviewController
      let destinationVC = segue.destinationViewController as! DetailedAlbumTableViewController
      destinationVC.currentAlbum = album
    }
  }
}
