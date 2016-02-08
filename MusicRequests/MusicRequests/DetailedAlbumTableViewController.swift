//
//  DetailedAlbumTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/8/16.
//
//

import UIKit

class DetailedAlbumTableViewController: ItemTableViewController {

  var currentAlbum: Album?
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentAlbum!.songs.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    let artistNames = currentAlbum!.artists.map({ $0.name }).joinWithSeparator(", ")

    cell.textLabel?.text = currentAlbum!.songs[indexPath.row].song.name
    cell.detailTextLabel?.text = "\(artistNames) • \(currentAlbum!.name)"
    cell.imageView?.image = currentAlbum!.imageToShow
    
    return cell
  }
  
}
