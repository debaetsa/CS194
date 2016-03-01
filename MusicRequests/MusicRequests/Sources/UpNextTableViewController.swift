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

    let queueItem = items[indexPath.row]

    let prefix: String
    if let localQueueItem = queueItem as? LocalQueueItem {
      prefix = "[\(localQueueItem.votes) Vote(s)] "

    } else if let remoteQueueItem = queueItem as? RemoteQueueItem {
      prefix = "[\(remoteQueueItem.request.vote)] "

    } else {
      prefix = ""
    }

    cell.textLabel?.text = "\(prefix)\(queueItem.song.name)"
    cell.detailTextLabel?.text = queueItem.song.artistAlbumString
    cell.imageView?.image = queueItem.song.album!.imageToShow

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
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let currentSession = AppDelegate.sharedDelegate.currentSession
    let maybeRemoteSession = currentSession as? RemoteSession
    let maybeLocalSession = currentSession as? LocalSession

    let upvote = UITableViewRowAction(style: .Normal, title: "+") { [unowned self] action, index in
      let queueItem = self.items[index.row]

      if let remoteSession = maybeRemoteSession {
        remoteSession.remoteQueue.upvote(withQueueItem: queueItem as! RemoteQueueItem)
      }
      if let _ = maybeLocalSession {
        // TODO: Need to perform the local action, whatever that may be.  For
        // now, we'll let that be an action to vote for the Song.
        print("Need to handle upvote request from host device.")
      }
    }
    upvote.backgroundColor = UIColor.blueColor()

    let downvote = UITableViewRowAction(style: .Normal, title: "-") { [unowned self] action, index in
      let queueItem = self.items[index.row]

      if let remoteSession = maybeRemoteSession {
        remoteSession.remoteQueue.downvote(withQueueItem: queueItem as! RemoteQueueItem)
      }
      if let _ = maybeLocalSession {
        // TODO: Need to perform the local action, whatever that may be.  For
        // now, we'll let that be an action to vote for the Song.
        print("Need to handle downvote request from host device.")
      }
    }
    downvote.backgroundColor = UIColor.redColor()

    return [downvote, upvote]
  }
}
