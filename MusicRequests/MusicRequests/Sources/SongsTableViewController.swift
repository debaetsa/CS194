//
//  SongsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongsTableViewController: ItemTableViewController {
  


  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allSongs.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let songs = library.allSongs
    let currentSong = songs[indexPath.row]
    let artistNames = currentSong.artists.map({ $0.name }).joinWithSeparator(", ")

    cell.textLabel?.text = currentSong.name
    cell.detailTextLabel?.text = "\(artistNames) - \(songs[indexPath.row].album!.name)"
    cell.imageView?.image = UIImage(named: "hozier_album.png")!


    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let clickedOnSong = library.allSongs[indexPath.row]
    songTitle = clickedOnSong.name
    artistName = clickedOnSong.artists.map({ $0.name }).joinWithSeparator(", ")
    albumName = clickedOnSong.album!.name
    
    performSegueWithIdentifier("ToPreview", sender: self)
  }

  
}
