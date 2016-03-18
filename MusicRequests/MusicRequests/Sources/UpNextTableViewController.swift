//
//  UpNextTableViewController.swift
//  Music Requests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class UpNextTableViewController: ItemListTableViewController {

  override func viewDidLoad() {
    shouldShowSearchBar = false  // don't add search bar here

    super.viewDidLoad()
  }

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

  // either the items or nothing if they aren't yet loaded
  var maybeItems: ([QueueItem], QueueItem?, [QueueItem])?

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
    if let queue = maybeQueue {
      maybeItems = (queue.history, queue.current, queue.upcoming)
    } else {
      maybeItems = nil
    }
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if let _ = maybeItems {
      return 3
    } else {
      return 1  // only one when loading
    }
  }

  enum Section: Int {
    case Previous = 0
    case Current
    case Upcoming
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let (previous, current, upcoming) = maybeItems {
      switch Section(rawValue: section)! {  // unwrap to catch errors
      case .Previous: return previous.count
      case .Current:  return (current != nil) ? 1 : 0
      case .Upcoming: return upcoming.count
      }

    } else {
      return 1  // one row when loading
    }
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let items = maybeItems {
      let queueItem: QueueItem
      switch Section(rawValue: indexPath.section)! {
      case .Previous: queueItem = items.0[indexPath.row]
      case .Current:  queueItem = items.1!  // it better exist if we request it
      case .Upcoming: queueItem = items.2[indexPath.row]
      }

      let isPlayingRow = (indexPath.section == 1)
      let cell = tableView.dequeueReusableCellWithIdentifier(isPlayingRow ? "NowPlaying" : "Item", forIndexPath: indexPath) as! QueueTableViewCell

      cell.updateContent(withQueueItem: queueItem)
      cell.selectionStyle = isPlayingRow ? .Default : .None
      cell.delegate = (indexPath.section == 2) ? self : nil
      return cell

      var imageView: UIImageView?
      var vote = Request.Vote.None
      
      if let localQueueItem = queueItem as? LocalQueueItem {
        vote = localQueueItem.song.cachedVote
      } else if let remoteQueueItem = queueItem as? RemoteQueueItem {
        vote = remoteQueueItem.request.vote
      }

      imageView = UIImageView(frame: CGRectMake(0, 0, 28.0, 28.0))
      if (vote == .Up) {
        imageView!.image = UIImage(named: "up_vote")
      } else if (vote == .Down) {
        imageView!.image = UIImage(named: "down_vote")
      } else {
        imageView = nil
      }
      
      cell.accessoryView = imageView
  

    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("Loading", forIndexPath: indexPath)
      cell.textLabel?.text = "Loading…"
      cell.selectionStyle = .None
      return cell
    }
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return (indexPath.section == 1) ? 100 : 50
  }

  @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}

extension UpNextTableViewController: SwipeTableViewCellDelegate {
  func swipeTableViewCell(cell: SwipeTableViewCell, didPressButton: SwipeTableViewCell.Location) {
  }
}
