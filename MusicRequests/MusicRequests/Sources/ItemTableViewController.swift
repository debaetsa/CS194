//
//  ItemTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/24/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class ItemTableViewController: UITableViewController {

  // This will access the shared library for the entire application.  This
  // avoids instantiating an entire Library instance for each view controller
  // which, in addition to being inefficient, would not actually work properly
  // once we start using the AppleLibrary.  Because we only want a single copy
  // of each song, we need to make sure that we don't import the data more than
  // once.
  let library = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.library)!

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
}
