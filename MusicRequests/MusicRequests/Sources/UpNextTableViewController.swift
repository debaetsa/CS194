//
//  UpNextTableViewController.swift
//  Music Requests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class UpNextTableViewController: ItemTableViewController, SessionChanged {

  var listener: NSObjectProtocol?
  
  var items = [QueueItem]()
  var currentIndex: Int?

  override func viewDidLoad() {
    super.viewDidLoad()

    // add a listener -- technically means that this will never go away
    AppDelegate.sharedDelegate.addSessionChangedListener(self)

    updateQueueObserver()
    self.updateData()  // load the initial data
    
  }

  override func viewDidAppear(animated: Bool) {
    self.updateData()
    self.tableView.reloadData()
  }
  
  func getQueue() -> Queue {
    return self.queue
  }
  
  deinit {
    if let listener = self.listener {
      let center = NSNotificationCenter.defaultCenter()
      center.removeObserver(listener)
    }
  }

  func updateQueueObserver() {
    let center = NSNotificationCenter.defaultCenter()

    if let listener = self.listener {
      center.removeObserver(listener)
    }

    listener = center.addObserverForName(Queue.didChangeNowPlayingNotification, object: queue, queue: nil) {
      [unowned self] (note) in
      self.updateData()
      self.tableView.reloadData()
    }
  }

  func didChangeSession(newSession: Session) {
    queue = AppDelegate.sharedDelegate.queue
    updateQueueObserver()
    updateData()
    tableView.reloadData()
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
    return indexPath
//    return (indexPath.row == currentIndex) ? indexPath : nil
  }

  @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func tableView(tableView: UITableView,
    editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
      let upvote = UITableViewRowAction(style: .Normal, title: "+") { action, index in
        let currentSong = self.items[indexPath.row].song;
        if let remoteQueue = AppDelegate.sharedDelegate.currentSession.queue as? RemoteQueue {
          remoteQueue.upvote(withQueueItem: self.items[indexPath.row])
          print("Upvoted song from listener device: \(currentSong.name): \(currentSong.votes!)");
        } else {
          currentSong.votes! += 1;
          self.updateData();
          self.tableView.reloadData()
          AppDelegate.sharedDelegate.localSession.sendQueueIfNeeded()
          print("Upvoted song from host device: \(currentSong.name): \(currentSong.votes!)");
        }
      }
      upvote.backgroundColor = UIColor.blueColor()
      
      let downvote = UITableViewRowAction(style: .Normal, title: "-") { action, index in
        let currentSong = self.items[indexPath.row].song;
        if let remoteQueue = AppDelegate.sharedDelegate.currentSession.queue as? RemoteQueue {
          remoteQueue.downvote(withQueueItem: self.items[indexPath.row])
          print("Downvoted song from listener device: \(currentSong.name): \(currentSong.votes!)");
        } else {
          currentSong.votes! -= 1;
          self.updateData();
          self.tableView.reloadData()
          AppDelegate.sharedDelegate.localSession.sendQueueIfNeeded()
          print("Downvoted song from host device: \(currentSong.name): \(currentSong.votes!)");
        }
      }
      downvote.backgroundColor = UIColor.redColor()
      
      return [downvote, upvote]
  }
}
