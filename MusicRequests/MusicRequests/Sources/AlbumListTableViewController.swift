//
//  AlbumsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class AlbumListTableViewController: ItemListTableViewController {

  var maybeItems: [Album]?

  override func viewDidLoad() {
    if let _ = maybeItems {
      containsFilteredItems = true
    }

    super.viewDidLoad()
  }

  override func reloadItems() {
    super.reloadItems()

    maybeItems = loadedLibrary?.allAlbums
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return maybeItems?.count ?? 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    if let items = maybeItems {
      let album = items[indexPath.row]

      var components = [String]()
      if let artist = album.artist {
        components.append(artist.name)
      }
      components.append(album.songs.count.pluralize(("Song", "Songs")))
      
      cell.textLabel?.text = album.name
      cell.detailTextLabel?.text = components.joinWithSeparator(" • ")
      cell.imageView?.image = album.imageToShow
      cell.selectionStyle = .Default

    } else {
      cell.textLabel?.text = "Loading…"
      cell.selectionStyle = .None
    }
    
    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushSongList", let items = maybeItems {
      let destination = segue.destinationViewController as! SongListTableViewController
      let indexPath = indexPathForSender(sender)
      let album = items[indexPath.row]
      destination.navigationItem.title = album.name
      destination.setTrackList(album.allSongs)
      destination.showDetails = false
    }
  }
}
