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
    if let items = maybeItems {
      let cell = tableView.dequeueReusableCellWithIdentifier("Standard", forIndexPath: indexPath) as! StandardTableViewCell

      let album = items[indexPath.row]

      var components = [String]()
      if let artist = album.artist {
        components.append(artist.name)
      }
      components.append(album.songs.count.pluralize(("Song", "Songs")))
      
      cell.customTextLabel.text = album.name
      cell.customDetailTextLabel.text = components.joinWithSeparator(" • ")
      cell.customImageView.image = album.imageToShow
      cell.selectionStyle = .Default

      return cell

    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("Loading", forIndexPath: indexPath)
      cell.textLabel?.text = "Loading…"
      cell.selectionStyle = .None
      return cell
    }
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
