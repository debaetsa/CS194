//
//  Style.swift
//  MusicRequests
//
//  Created by James Matthew Capps on 2/22/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import Foundation
import UIKit

struct Style {

  static var black = UIColor.blackColor()
  static var dark = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
  static var darkGray = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
  static var gray = UIColor.grayColor()
  static var lightGray = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
  static var white = UIColor.whiteColor()
  static var clear = UIColor.clearColor()


  struct darkTheme {

    // This function is called in AppDelegate.swift on initial launch of the app within the function
    // "application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool"
    static func standardView() {

      // Change color of background color of the table views
      UITableView.appearance().backgroundColor = dark
      // Change color of cells in table views
      UITableViewCell.appearance().backgroundColor = dark
      // Change color of text in labels
      UILabel.appearance().textColor = white

      // Change color of navigation bar
      UINavigationBar.appearance().barTintColor = darkGray
      // Change color of title in navigation bar
      UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: white]
      // Change color of navigation links in navigation bar
      UINavigationBar.appearance().tintColor = lightGray

      // Change color of tab bar
      UITabBar.appearance().barTintColor = darkGray
      // Change color of selected icon in tab bar
      UITabBar.appearance().tintColor = white
      // Change color of unselected icon text in tab bar
      UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: gray], forState: .Normal)
      // Change color of selected icon text in tab bar
      UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: white], forState: .Selected)

    }

    // This function is called in SourceTableViewController.swift within the function 
    // "tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)"
    static func sourceView(tableView: UITableView, header: UITableViewHeaderFooterView) {

      // Change color of background in Source
      tableView.backgroundColor = black
      // Change color of headers in Source
      header.contentView.backgroundColor = black
      // Change color of header text labels in Source
      header.textLabel!.textColor = gray
    }

  }

}
