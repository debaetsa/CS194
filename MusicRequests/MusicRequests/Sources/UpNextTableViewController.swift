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

  override func viewDidAppear(animated: Bool) {
    self.updateData()
    self.tableView.reloadData()
  }
  
  deinit {
    if let listener = self.listener {
      let center = NSNotificationCenter.defaultCenter()
      center.removeObserver(listener)
    }
  }

  private func updateData() {
    print("UpdateData() called.")
    items.removeAll()
    items.appendContentsOf(queue.history)
    if let current = queue.current {
      currentIndex = items.count
      items.append(current)
    } else {
      currentIndex = nil  // there is not a playing item
    }
    queue.refreshUpcoming()
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
    cell.textLabel?.text = song.name
    cell.detailTextLabel?.text = "\(song.artistAlbumString), Votes: \(song.votes!)"
    cell.imageView?.image = song.album!.imageToShow

    return cell
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return (indexPath.row == currentIndex) ? 100 : 50
  }

  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    return (indexPath.row == currentIndex) ? indexPath : nil
  }

  @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func tableView(tableView: UITableView,
    editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
      let upvote = UITableViewRowAction(style: .Normal, title: "+") { action, index in
      let currentSong = self.items[indexPath.row].song;
        currentSong.votes! += 1;
        self.updateData();
        self.tableView.reloadData()
        print("Upvoted song: \(currentSong.name): \(currentSong.votes!)");
      }
      upvote.backgroundColor = UIColor.blueColor()
      
      let downvote = UITableViewRowAction(style: .Normal, title: "-") { action, index in
        let currentSong = self.items[indexPath.row].song;
        currentSong.votes! -= 1;
        self.updateData();
        self.tableView.reloadData()
        print("Upvoted song: \(currentSong.name): \(currentSong.votes!)");
      }
      downvote.backgroundColor = UIColor.redColor()
      
      return [downvote, upvote]
  }
}
