//
//  SearchTableViewController.swift
//  MusicRequests
//
//  Created by Max Radermacher on 3/3/16.
//
//

import UIKit

class SearchTableViewController: UITableViewController {

  var allItems = [Item]()
  var filteredItems = [Item]()

  override func viewDidLoad() {
    super.viewDidLoad()

    if let library = AppDelegate.sharedDelegate.currentSession.library {
      for artist in library.allArtists {
        allItems.append(artist)
      }
      for song in library.allSongs {
        allItems.append(song)
      }
      for album in library.allAlbums {
        allItems.append(album)
      }
    }
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredItems.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Identifier") ?? UITableViewCell(style: .Default, reuseIdentifier: "Identifier")

    let item = filteredItems[indexPath.row]
    cell.textLabel?.text = item.name
    cell.textLabel?.textColor = UIColor.whiteColor()

    // don't show the disclosure indicator for Songs
    if item is Song {
      cell.accessoryType = .None
      cell.selectionStyle = .None
    } else {
      cell.accessoryType = .DisclosureIndicator
      cell.selectionStyle = .Default
    }

    return cell
  }

  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      if cell.selectionStyle != .None {
        return indexPath
      }
    }
    return nil
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let item = filteredItems[indexPath.row]

    if item is Artist {
      // TODO: show the Artist details
    } else if item is Album {
      // TODO: show the Album details
    }
  }

  private func filterWithString(maybeString: String?) {
    if let string = maybeString {
      let terms = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter {
        $0.characters.count > 0
      }
      filteredItems = allItems.filter { item in
        for term in terms {
          if !item.name.localizedCaseInsensitiveContainsString(term) {
            return false
          }
        }
        return true
      }

    } else {
      filteredItems = allItems
    }

    tableView.reloadData()
  }
}

extension SearchTableViewController : UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterWithString(searchController.searchBar.text)
  }
}
