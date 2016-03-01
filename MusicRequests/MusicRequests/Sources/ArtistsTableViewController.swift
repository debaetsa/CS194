//
//  ArtistsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ArtistsTableViewController: ItemTableViewController {
  var artists: [Artist] = []
  var album: Album?
  var artist: Artist?
  var song: Song?
  let searchController = UISearchController(searchResultsController: nil)
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(!self.searchController.active || searchController.searchBar.text == ""){
      return library.allArtists.count
    } else {
      return artists.count
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    
    if(!self.searchController.active || searchController.searchBar.text == ""){
      artists = library.allArtists
    }
    let currentArtist = artists[indexPath.row]
    let albums = currentArtist.allAlbums
    let albumCount = albums.count
    let songCount = albums.reduce(0) { $0 + $1.songs.count }
    
    
    // currentArtist.name is a String, so it doesn't need to be wrapped in
    // "\()" unless something else is being added to it.  It's redundant.
    cell.textLabel?.text = currentArtist.name
    cell.detailTextLabel?.text = "\(albumCount.pluralize(("Album", "Albums"))) • \(songCount.pluralize(("Song", "Songs")))"
    cell.imageView?.image = currentArtist.allAlbums[0].imageToShow
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    artist = artists[indexPath.row]
    performSegueWithIdentifier("ToArtistDetail", sender: self)
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if (segue.identifier == "ToArtistDetail") {
      // Create a new variable to store the instance of PreviewController
      let destinationVC = segue.destinationViewController as! DetailedArtistTableViewController
      destinationVC.artist = artist
    }
  }
  func filterContentForSearchText(searchText: String, scope: String = "All") {
    artists = library.allArtists.filter { artist in
      return artist.name.lowercaseString.containsString(searchText.lowercaseString)
    }
    tableView.reloadData()
  }
}

extension ArtistsTableViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}