//
//  UpNextTableViewController.swift
//  Music Requests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class UpNextTableViewController: ItemTableViewController {

  var album: Album?
  var artist: Artist?
  var song: Song?
  var listener: NSObjectProtocol?

  var items = [QueueItem]()
  var currentIndex: Int?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.updateData()  // load the initial data

    let center = NSNotificationCenter.defaultCenter()
    listener = center.addObserverForName(Queue.didChangeNowPlayingNotification, object: nil, queue: nil, usingBlock: {
      [unowned self] (note) in
      self.updateData()
      self.tableView.reloadData()
      }
    )
  }

  deinit {
    if let listener = self.listener {
      let center = NSNotificationCenter.defaultCenter()
      center.removeObserver(listener)
    }
  }

  private func updateData() {
    items.removeAll()
    items.appendContentsOf(queue.history)
    if let current = queue.current {
      currentIndex = items.count
      items.append(current)
    } else {
      currentIndex = nil  // there is not a playing item
    }
    items.appendContentsOf(queue.upcoming)
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell: UITableViewCell

    let isPlayingRow = (indexPath.row == currentIndex)

    if (isPlayingRow) {
      cell = tableView.dequeueReusableCellWithIdentifier("BigCell", forIndexPath: indexPath)
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    }

    let song = items[indexPath.row].song

    var detailComponents = [String]()
    if let name = song.artist?.name {
      detailComponents.append(name)
    }
    if let name = song.album?.name {
      detailComponents.append(name)
    }

    cell.textLabel?.text = song.name
    cell.detailTextLabel?.text = detailComponents.joinWithSeparator(" • ")
    cell.imageView?.image = song.album!.imageToShow

    return cell
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return (indexPath.row == currentIndex) ? 100 : 50
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let clickedOnSong = library.allSongs[indexPath.row]
    song = clickedOnSong
    artist = clickedOnSong.artist
    album = clickedOnSong.album
    performSegueWithIdentifier("ToPreview", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if (segue.identifier == "ToPreview") {
      // Create a new variable to store the instance of PreviewController
      let destinationVC = segue.destinationViewController as! PreviewController
      destinationVC.song = song
      destinationVC.artist = artist
      destinationVC.album = album
    }
  }
}
