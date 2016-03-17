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

  static var veryDark = UIColor(red: 0.025, green: 0.025, blue: 0.025, alpha: 1.0)
  static var dark = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
  static var darkGray = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
  static var mediumGray = UIColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1.0)
  static var gray = UIColor.grayColor()
  static var lightGray = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
  static var lightBlue = UIColor(red: 0.68, green: 0.68, blue: 1.0, alpha: 1.0)
  static var white = UIColor.whiteColor()
  static var clear = UIColor.clearColor()

  static var red = UIColor.redColor()
  static var yellow = UIColor.yellowColor()


  struct darkTheme {

    // This function is called in AppDelegate.swift on initial launch of the app within the function
    // "application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool"
    static func standardView() {

      // Change color of status bar
      UIApplication.sharedApplication().statusBarStyle = .LightContent
      // Show status bar after launch screen (bar is hidden in Info.plist)
      UIApplication.sharedApplication().statusBarHidden = false

      // Change color of play controls in Up Next view
      UIToolbar.appearance().tintColor = gray
      // Change color of toolbar behind play controls in Up Next view
      UIToolbar.appearance().barTintColor = veryDark
      // Remove line dividing toolbar from table view
      UIToolbar.appearance().clipsToBounds = true

      // Change color of background color of the table views
      UITableView.appearance().backgroundColor = dark
      // Change color of separator lines in table view
      UITableView.appearance().separatorColor = mediumGray
      // Change color of cells in table views
      UITableViewCell.appearance().backgroundColor = dark
      // Change color of checkmark in sources view
      UITableViewCell.appearance().tintColor = lightBlue
      // Change color of text in labels
      UILabel.appearance().textColor = white

      // Change color of navigation bar
      UINavigationBar.appearance().barTintColor = darkGray
      // Change color of title in navigation bar
      UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: white]
      // Change color of navigation links in navigation bar
      UINavigationBar.appearance().tintColor = lightGray

      // Change the basic style of the search bar
      UISearchBar.appearance().barStyle = UIBarStyle.Black
      // Change color surrounding the search field
      UISearchBar.appearance().barTintColor = dark
      // Change color of the cancel button in the search bar
      UISearchBar.appearance().tintColor = lightGray
      // Change color of text typed in search bar
      UITextField.appearance().textColor = lightGray

      // Change color of tab bar
      UITabBar.appearance().barTintColor = darkGray
      // Change color of selected icon in tab bar
      UITabBar.appearance().tintColor = white
      // Change color of unselected icon text in tab bar
      UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: gray], forState: .Normal)
      // Change color of selected icon text in tab bar
      UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: white], forState: .Selected)

      // Change color of the "on" position of the switch in sources view
      UISwitch.appearance().onTintColor = lightBlue

    }

    // This function is called in SourceTableViewController.swift within the function
    // "tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)"
    static func sourceView(tableView: UITableView, header: UITableViewHeaderFooterView, textField: UITextField) {

      // Change color of background in Source
      tableView.backgroundColor = veryDark
      // Change color of headers in Source
      header.contentView.backgroundColor = veryDark
      // Change color of header text labels in Source
      header.textLabel!.textColor = gray

      // Change text and color of the placeholder text in text field in Source
      textField.attributedPlaceholder = NSAttributedString(string: "Playlist Name Here", attributes: [NSForegroundColorAttributeName: gray])
      // Change color of typed text in text field in Source
      textField.textColor = white
    }
    
  }
  
}
