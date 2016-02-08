//
//  DetailedAlbumTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/8/16.
//
//

import UIKit

class DetailedAlbumTableViewController: ItemTableViewController {
  var album: Album?
  var artist: Artist?
  var song: Song?
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return album!.songs.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    let artistNames = album!.artists.map({ $0.name }).joinWithSeparator(", ")

    cell.textLabel?.text = album!.songs[indexPath.row].song.name
    cell.detailTextLabel?.text = "\(artistNames) • \(album!.name)"
    cell.imageView?.image = album!.imageToShow
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let clickedOnSong = album!.allSongs[indexPath.row].song
    song = clickedOnSong
    artist = clickedOnSong.artist
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
