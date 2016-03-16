//
//  ItemTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/24/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ItemListTableViewController: UITableViewController {

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


  // The application needs to handle the situation where the Library is not
  // accessible.  This can happen when the Library for a RemoteSession has not
  // yet been loaded.  It should be handled as if the Library isn't loaded.
  var loadedLibrary: Library? {
    if let library = maybeLibrary {
      if library.isLoaded {
        return library
      }
    }
    return nil
  }

  var containsFilteredItems = false

  func reloadItems() {
  }

  func libraryDidChange() {
    if !containsFilteredItems {
      reloadItems()
      tableView.reloadData()
    }
  }

  private var maybeLibrary: Library? {
    didSet {
      if oldValue !== maybeLibrary {
        // We have a new reference for the Library object, so notify subclasses.
        libraryDidChange()
      }
    }
  }

  func sessionDidChange() {
    let updateCurrentLibrary = {
      [unowned self] (note: NSNotification?) in

      self.maybeLibrary = AppDelegate.sharedDelegate.currentSession.library
    }

    let center = NSNotificationCenter.defaultCenter()
    if let listener = maybeLibraryChangedListener {
      center.removeObserver(listener)
    }
    maybeLibraryChangedListener = center.addObserverForName(
      Session.didChangeLibraryNotification, object: AppDelegate.sharedDelegate.currentSession, queue: nil, usingBlock: updateCurrentLibrary
    )
    updateCurrentLibrary(nil)  // update it for the new Session
  }

  var maybeLibraryChangedListener: NSObjectProtocol?
  var maybeSessionChangedListener: NSObjectProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()

    // This clears the background of each table view so that it displays
    // the correct color in the "bounce" area
    tableView.backgroundView = UIView()

    let updateCurrentSession = {
      [unowned self] (note: NSNotification?) in

      self.sessionDidChange()
    }

    let center = NSNotificationCenter.defaultCenter()
    maybeSessionChangedListener = center.addObserverForName(
      AppDelegate.didChangeSession, object: AppDelegate.sharedDelegate, queue: nil, usingBlock: updateCurrentSession
    )
    updateCurrentSession(nil)  // set the default value when loading
  }

  deinit {
    let center = NSNotificationCenter.defaultCenter()
    if let listener = maybeLibraryChangedListener {
      center.removeObserver(listener)
    }
    if let listener = maybeSessionChangedListener {
      center.removeObserver(listener)
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if let selectedIndexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRowAtIndexPath(selectedIndexPath, animated: animated)
    }
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
