//
//  AlbumsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class AlbumListTableViewController: ItemListTableViewController {

  var items: [Album]!

  override func viewDidLoad() {
    super.viewDidLoad()

    if items == nil {
      items = library.allAlbums
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let album = items[indexPath.row]

    var components = [String]()
    if let artist = album.artist {
      components.append(artist.name)
    }
    components.append(album.songs.count.pluralize(("Song", "Songs")))
    
    cell.textLabel?.text = album.name
    cell.detailTextLabel?.text = components.joinWithSeparator(" • ")
    cell.imageView?.image = album.imageToShow
    
    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushSongList" {
      let destination = segue.destinationViewController as! SongListTableViewController
      let indexPath = indexPathForSender(sender)
      let album = items[indexPath.row]
      destination.navigationItem.title = album.name
      destination.setTrackList(album.allSongs)
      destination.showDetails = false
    }
  }
}
