//
//  UpNextTableViewController.swift
//  Music Requests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class UpNextTableViewController: ItemListTableViewController {

  // This is posted when the contents of the Queue changed.
  var maybeQueueUpdatedListener: NSObjectProtocol?

  // Whereas this is posted when the Queue itself changes.  (This happens if or
  // when you switch the Session.)
  var maybeQueueChangedListener: NSObjectProtocol?
  var maybeQueue: Queue? {
    didSet {
      if oldValue !== maybeQueue {
        queueDidChange()
      }
    }
  }

  private func queueDidChange() {
    logger("queue changed to " + ((maybeQueue != nil) ? "value" : "nil"))

    let center = NSNotificationCenter.defaultCenter()

    if let listener = maybeQueueUpdatedListener {
      center.removeObserver(listener)
    }

    let updateCurrentQueue = {
      [unowned self] (note: NSNotification?) in

      self.updateData()
      self.tableView.reloadData()
    }

    if let queue = maybeQueue {
      maybeQueueUpdatedListener = center.addObserverForName(
        Queue.didChangeNowPlayingNotification, object: queue, queue: nil, usingBlock: updateCurrentQueue
      )
    }
    updateCurrentQueue(nil)  // refresh it always -- could have disappeared
  }

  var maybeItems: [QueueItem]?
  var currentIndex: Int?

  override func sessionDidChange() {
    super.sessionDidChange()

    let updateCurrentQueue = {
      [unowned self] (note: NSNotification?) in

      self.maybeQueue = AppDelegate.sharedDelegate.currentSession.queue
    }

    let center = NSNotificationCenter.defaultCenter()
    if let listener = maybeQueueChangedListener {
      center.removeObserver(listener)
    }
    maybeQueueChangedListener = center.addObserverForName(
      Session.didChangeQueueNotification, object: AppDelegate.sharedDelegate.currentSession, queue: nil, usingBlock: updateCurrentQueue
    )
    updateCurrentQueue(nil)  // set the starting value
  }

  deinit {
    let center = NSNotificationCenter.defaultCenter()
    if let listener = maybeQueueUpdatedListener {
      center.removeObserver(listener)
    }
    if let listener = maybeQueueChangedListener {
      center.removeObserver(listener)
    }
  }

  private func updateData() {
    currentIndex = nil

    if let queue = maybeQueue {
      var items = [QueueItem]()
      items.appendContentsOf(queue.history)
      if let current = queue.current {
        currentIndex = items.count
        items.append(current)
      }
      items.appendContentsOf(queue.upcoming)
      maybeItems = items

    } else {
      maybeItems = nil
    }
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return maybeItems?.count ?? 1
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: UITableViewCell

    let isPlayingRow = (indexPath.row == currentIndex)

    if let items = maybeItems {
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
      cell.selectionStyle = .Default

    } else {
      cell = tableView.dequeueReusableCellWithIdentifier("NormalCell", forIndexPath: indexPath)
      cell.textLabel?.text = "Loading…"
      cell.selectionStyle = .None
    }

    return cell
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return (indexPath.row == currentIndex) ? 100 : 50
  }

  @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {

    guard let items = maybeItems else {
      // If there aren't items, then we can't have any actions.
      return nil
    }

    let currentSession = AppDelegate.sharedDelegate.currentSession
    let maybeRemoteSession = currentSession as? RemoteSession
    let maybeLocalSession = currentSession as? LocalSession

    let upvote = UITableViewRowAction(style: .Normal, title: "+") { action, index in
      let queueItem = items[index.row]

      if let remoteSession = maybeRemoteSession {
//        remoteSession.remoteQueue.upvote(withQueueItem: queueItem as! RemoteQueueItem)
      }
      if let _ = maybeLocalSession {
        // TODO: Need to perform the local action, whatever that may be.  For
        // now, we'll let that be an action to vote for the Song.
        print("Need to handle upvote request from host device.")
      }
    }
    upvote.backgroundColor = UIColor.blueColor()

    let downvote = UITableViewRowAction(style: .Normal, title: "-") { action, index in
      let queueItem = items[index.row]

      if let remoteSession = maybeRemoteSession {
//        remoteSession.queue!.downvote(withQueueItem: queueItem as! RemoteQueueItem)
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
