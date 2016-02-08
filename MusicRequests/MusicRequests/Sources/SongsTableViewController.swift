//
//  SongsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongsTableViewController: ItemTableViewController {
  var album: Album?
  var artist: Artist?
  var song: Song?

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
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let clickedOnSong = library.allSongs[indexPath.row]
    song = clickedOnSong
    artist = clickedOnSong.artist
    album = clickedOnSong.album
    performSegueWithIdentifier("ToPreview", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if (segue.identifier == "ToPreview") {
      // Create a new variable to store the instance of PreviewController
      let destinationVC = segue.destinationViewController as! PreviewController
      destinationVC.song = song
      destinationVC.artist = artist
      destinationVC.album = album
    }
  }
}
