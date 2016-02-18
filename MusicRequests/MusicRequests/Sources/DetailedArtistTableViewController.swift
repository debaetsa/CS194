//
//  DetailedArtistTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/8/16.
//
//

import UIKit

class DetailedArtistTableViewController: ItemTableViewController {
  var album: Album?
  var artist: Artist?
  var song: Song?
  var artistName: String?
  var albumName: String?
  @IBOutlet weak var NavBar: UINavigationItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    NavBar.title = artistName
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return artist!.albumCount
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    let currentAlbum = artist!.allAlbums[indexPath.row]
    let artistNames = currentAlbum.artists.map({ $0.name }).joinWithSeparator(", ")
    let songCount = currentAlbum.songs.count
    
    cell.textLabel?.text = currentAlbum.name
    cell.detailTextLabel?.text = "\(artistNames) • \(songCount.pluralize(("Song", "Songs")))"
    cell.imageView?.image = currentAlbum.imageToShow
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    album = artist!.allAlbums[indexPath.row]
    albumName = album!.name
    performSegueWithIdentifier("ToAlbumDetail", sender: self)
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if (segue.identifier == "ToAlbumDetail") {
      // Create a new variable to store the instance of PreviewController
      let destinationVC = segue.destinationViewController as! DetailedAlbumTableViewController
      destinationVC.album = album
      destinationVC.albumName = albumName
    }
  }
}
