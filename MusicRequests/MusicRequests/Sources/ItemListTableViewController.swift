//
//  ItemTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/24/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ItemListTableViewController: UITableViewController {

  // The application needs to handle the situation where the Library is not
  // accessible.  This can happen when the Library for a RemoteSession has not
  // yet been loaded.  It should be handled as if the Library isn't loaded.
  var loadedLibrary: Library? {
    if let library = maybeLibrary {
      if library.isLoaded {
        return library

      } else {
        // The Library is not yet loaded, but there is an object.  We want to
        // trigger a refresh (and call libraryDidChange()) whenever this object
        // actually finishes loading.  We'll do that by requesting a callback.
        library.runWhenLoaded {
          [weak self] in

          // If we haven't been deallocated, then we care when the Library is
          // loaded.  If we have been deallocated, then we aren't being shown
          // to the user, so it doesn't matter if this doesn't get called.
          self?.libraryDidChange()
        }
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
