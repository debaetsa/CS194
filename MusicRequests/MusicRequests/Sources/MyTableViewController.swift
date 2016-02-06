//
//  MyTableViewController.swift
//  appName
//
//  Created by Matthew Volk on 1/24/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class MyTableViewController: UITableViewController {

  let library = TemporaryLibrary()

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
}
