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

  static var dark = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
  static var darkGray = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
  static var gray = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
  static var light = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

  static func darkTheme() {
    // Change color of background color of the table views
    UITableView.appearance().backgroundColor = Style.dark
    // Change color of cells in table views
    UITableViewCell.appearance().backgroundColor = Style.dark
    // Change color of text in labels
    UILabel.appearance().textColor = Style.light

    // Change color of navigation bar
    UINavigationBar.appearance().barTintColor = Style.darkGray
    // Change color of title in navigation bar
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Style.light]
    // Change color of navigation links in navigation bar
    UINavigationBar.appearance().tintColor = Style.light

    // Change color of tab bar
    UITabBar.appearance().barTintColor = Style.darkGray
    // Change color of selected icon in tab bar
    UITabBar.appearance().tintColor = Style.light
    // Change color of unselected icon text in tab bar
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Style.gray], forState: .Normal)
    // Change color of selected icon text in tab bar
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Style.light], forState: .Selected)
  }

}
