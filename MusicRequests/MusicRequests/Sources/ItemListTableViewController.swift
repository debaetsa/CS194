//
//  ItemTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/24/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ItemListTableViewController: UITableViewController {

  // This will access the shared library for the entire application.  This
  // avoids instantiating an entire Library instance for each view controller
  // which, in addition to being inefficient, would not actually work properly
  // once we start using the AppleLibrary.  Because we only want a single copy
  // of each song, we need to make sure that we don't import the data more than
  // once.  We wait until the view controller is loaded to retrieve the object
  // to give the AppDelegate a chance to load it.
  var library: Library!

  // The search results controller is used when searching for items.  It only
  // searches the particular item type, though it should probably search all
  // of the item types.  That can be changed later.
  let searchController = UISearchController(searchResultsController: nil)

  //    if(!self.searchController.active || searchController.searchBar.text == ""){
  //      return library.allSongs.count
  //    } else {
  //    }

  //    searchController.searchResultsUpdater = self
  //    searchController.dimsBackgroundDuringPresentation = false
  //    searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
  //    definesPresentationContext = true
  //    tableView.tableHeaderView = searchController.searchBar

  //    if(!self.searchController.active || searchController.searchBar.text == ""){
  //      songs = library.allSongs
  //    }

  //extension SongsTableViewController: UISearchResultsUpdating {
  //  func updateSearchResultsForSearchController(searchController: UISearchController) {
  //    filterContentForSearchText(searchController.searchBar.text!)
  //  }
  //}

  //  func filterContentForSearchText(searchText: String, scope: String = "All") {
  //    songs = library.allSongs.filter { song in
  //      return song.name.lowercaseString.containsString(searchText.lowercaseString)
  //    }
  //    tableView.reloadData()
  //  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // This clears the background of each table view so that it displays
    // the correct color in the "bounce" area
    tableView.backgroundView = UIView()

    library = AppDelegate.sharedDelegate.library
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50
  }

  func indexPathForSender(sender: AnyObject) -> NSIndexPath {
    return tableView.indexPathForCell(sender as! UITableViewCell)!
  }
}
