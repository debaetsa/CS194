//
//  SongsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongListTableViewController: ItemListTableViewController {

  var numberedItems: [(Int?, Song)]!
  var showNumbers = false

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberedItems.count
  }

  func setSongList(songs: [Song], addTrackNumbers: Bool = false) {
    numberedItems = songs.map { (nil, $0) }
    if addTrackNumbers {
      for index in 0..<numberedItems.count {
        numberedItems[index].0 = (index + 1)
      }
    }
    showNumbers = addTrackNumbers
  }

  func setTrackList(tracks: [Track]) {
    numberedItems = tracks.map { ($0.track, $0.song) }
    showNumbers = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if numberedItems == nil {
      setSongList(library.allSongs)
    }
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let (number, song) = numberedItems[indexPath.row]

    cell.textLabel?.text = song.name
    if showNumbers {
      cell.detailTextLabel?.text = (number != nil) ? "\(number!)" : nil
    } else {
      cell.detailTextLabel?.text = song.artistAlbumString
    }
    cell.imageView?.image = song.album!.imageToShow

    return cell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "PushSongPreview" {
      let destination = segue.destinationViewController as! SongViewController
      let indexPath = indexPathForSender(sender)

      let (_, song) = numberedItems[indexPath.row]
      destination.song = song
    }
  }
}

