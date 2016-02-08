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

    var detailComponents = [String]()
    if let name = currentSong.artist?.name {
      detailComponents.append(name)
    }
    if let name = currentSong.album?.name {
      detailComponents.append(name)
    }
    cell.detailTextLabel?.text = detailComponents.joinWithSeparator(" • ")

    cell.textLabel?.text = currentSong.name
    cell.imageView?.image = currentSong.album!.imageToShow

    return cell
  }

//  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    let clickedOnSong = library.allSongs[indexPath.row]
//    songTitle = clickedOnSong.name
//    artistName = clickedOnSong.artist!.name
//    albumName = clickedOnSong.album!.name
//    
//    performSegueWithIdentifier("ToPreview", sender: self)
//  }

  
}
