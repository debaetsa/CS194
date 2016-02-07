//
//  UpNextTableViewController.swift
//  Music Requests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class UpNextTableViewController: ItemTableViewController {

  var listener: NSObjectProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()

    let center = NSNotificationCenter.defaultCenter()
    listener = center.addObserverForName(Queue.didChangeNowPlayingNotification, object: nil, queue: nil, usingBlock: { (note) in
      if let queue = (note.object as? Queue) {
        print("New Song: \(queue.current); Next Up Is: \(queue.upcoming.first)")
      }
    })
  }

  deinit {
    if let listener = self.listener {
      let center = NSNotificationCenter.defaultCenter()
      center.removeObserver(listener)
    }
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return library.allSongs.count
  }


  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let songs = library.allSongs

    var cell: UITableViewCell
    if (indexPath.row == 4) {
      cell = tableView.dequeueReusableCellWithIdentifier("BigCell", forIndexPath: indexPath)
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    }
    let currentSong = songs[indexPath.row]

    cell.textLabel?.text = "\(currentSong.name)"

    let artistNames = currentSong.artists.map{String($0)}.joinWithSeparator(", ")

    cell.detailTextLabel?.text = "\(artistNames) - \(songs[indexPath.row].album!.name)"

    return cell
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    // "4" Hardcoded for now, will replace with currently_playing song next week

    if(indexPath.row != 4) {
      return 50.0
    }
    return 100.0
  }
}
