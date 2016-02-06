//
//  SongsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongsTableViewController: ItemTableViewController {

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allSongs.count
  }


  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let songs = library.allSongs

    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let currentSong = songs[indexPath.row]

    cell.textLabel?.text = "\(currentSong.name)"

    let artistNames = currentSong.artists.map{String($0)}.joinWithSeparator(", ")

    cell.detailTextLabel?.text = "\(artistNames) - \(songs[indexPath.row].album!.name)"

    return cell
  }
}
