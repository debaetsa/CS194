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
  static var light = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

  static func darkTheme() {
    UITableView.appearance().backgroundColor = Style.dark
    UITableViewCell.appearance().backgroundColor = Style.dark
    UILabel.appearance().textColor = Style.light

    UINavigationBar.appearance().barTintColor = Style.darkGray
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Style.light]
    UINavigationBar.appearance().tintColor = Style.light

    UITabBar.appearance().barTintColor = Style.darkGray
    UITabBar.appearance().tintColor = Style.light
  }

}
