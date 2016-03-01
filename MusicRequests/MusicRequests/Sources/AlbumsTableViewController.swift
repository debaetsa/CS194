//
//  AlbumsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class AlbumsTableViewController: ItemTableViewController {
  var albums: [Album] = []
  var album: Album?
  var artist: Artist?
  var song: Song?
  
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(!self.searchController.active || searchController.searchBar.text == ""){
      return library.allAlbums.count
    } else {
      return albums.count
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    
    if(!self.searchController.active || searchController.searchBar.text == ""){
      albums = library.allAlbums
    }
    let currentAlbum = albums[indexPath.row]
    let artistNames = currentAlbum.artists.map({ $0.name }).joinWithSeparator(", ")
    let songCount = currentAlbum.songs.count
    
    cell.textLabel?.text = currentAlbum.name
    cell.detailTextLabel?.text = "\(artistNames) • \(songCount.pluralize(("Song", "Songs")))"
    cell.imageView?.image = currentAlbum.imageToShow
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    album = albums[indexPath.row]
    performSegueWithIdentifier("ToAlbumDetail", sender: self)
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if (segue.identifier == "ToAlbumDetail") {
      // Create a new variable to store the instance of PreviewController
      let destinationVC = segue.destinationViewController as! DetailedAlbumTableViewController
      destinationVC.album = album
    }
  }
  
  func filterContentForSearchText(searchText: String, scope: String = "All") {
    albums = library.allAlbums.filter { album in
      return album.name.lowercaseString.containsString(searchText.lowercaseString)
    }
    tableView.reloadData()
  }
}

extension AlbumsTableViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}