//
//  SongsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongsTableViewController: ItemTableViewController {
  
  let searchController = UISearchController(searchResultsController: nil)
  var songs : [Song] = []
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(!self.searchController.active || searchController.searchBar.text == ""){
      return library.allSongs.count
    } else {
      return songs.count
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    
    if(!self.searchController.active || searchController.searchBar.text == ""){
      songs = library.allSongs
    }
    
    let currentSong = songs[indexPath.row]
    
    cell.textLabel?.text = currentSong.name
    cell.detailTextLabel?.text = currentSong.artistAlbumString
    cell.imageView?.image = currentSong.album!.imageToShow
    
    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "preview" {
      let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
      let destination = segue.destinationViewController as! SongViewController
      destination.song = songs[indexPath.row]
    }
  }
  
  func filterContentForSearchText(searchText: String, scope: String = "All") {
    songs = library.allSongs.filter { song in
      return song.name.lowercaseString.containsString(searchText.lowercaseString)
    }
    tableView.reloadData()
  }
}

extension SongsTableViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}
