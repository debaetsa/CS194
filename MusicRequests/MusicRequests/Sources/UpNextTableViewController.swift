//
//  UpNextTableViewController.swift
//  Music Requests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class UpNextTableViewController: ItemListTableViewController {

  // we need a reference to be able to pass the scroll information
  weak var mainViewController: MainViewController?
  @IBOutlet var nowPlayingView: NowPlayingView!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.showsVerticalScrollIndicator = false  // hide the scroll bar
    nowPlayingView.delegate = self
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    mainViewController?.updateViewPosition(inTableView: tableView)
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
      self.nowPlayingView.updateContent(withQueueItem: self.maybeItems?.1)
      self.mainViewController?.updateViewPosition(inTableView: self.tableView)
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

  // Convert an image to grayscale. Reference: http://myxcode.net/2015/08/30/converting-an-image-to-black-white-in-swift/
  func convertToGrayScale(image: UIImage) -> UIImage {
    let imageRect:CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let width = image.size.width
    let height = image.size.height

    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
    let context = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, colorSpace, bitmapInfo.rawValue)

    CGContextDrawImage(context, imageRect, image.CGImage)
    let imageRef = CGBitmapContextCreateImage(context)
    let newImage = UIImage(CGImage: imageRef!)
    
    return newImage
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

      if isPlayingRow {
        let cell = tableView.dequeueReusableCellWithIdentifier("NowPlaying", forIndexPath: indexPath)
        cell.textLabel?.text = nil
        cell.selectionStyle = .Default
        return cell

      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("Item", forIndexPath: indexPath) as! QueueTableViewCell

        cell.updateContent(withQueueItem: queueItem)
        cell.selectionStyle = isPlayingRow ? .Default : .None
        cell.delegate = (indexPath.section == 2) ? self : nil

        if indexPath.section == 0 {
          cell.customTextLabel?.textColor = Style.gray
          cell.customDetailTextLabel?.textColor = Style.gray
          cell.customImageView?.image = convertToGrayScale((cell.customImageView?.image)!)
        } else {
          cell.customTextLabel?.textColor = Style.white
          cell.customDetailTextLabel?.textColor = Style.white
        }

        return cell
      }

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

  // MARK: - Scrolling

  override func scrollViewDidScroll(scrollView: UIScrollView) {
    mainViewController?.updateViewPosition(inTableView: tableView)
  }

  // MARK: - Dismissing Modal Controllers

  @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}

extension UpNextTableViewController: SwipeTableViewCellDelegate {
  func swipeTableViewCell(cell: SwipeTableViewCell, didPressButton button: SwipeTableViewCell.Direction) {
    if let items = maybeItems, let indexPath = tableView.indexPathForCell(cell) {
      let queueItem: QueueItem
      switch Section(rawValue: indexPath.section)! {
      case .Previous: queueItem = items.0[indexPath.row]
      case .Current:  queueItem = items.1!  // it better exist if we request it
      case .Upcoming: queueItem = items.2[indexPath.row]
      }

      // We have the QueueItem, so determine what we should do with it.
      if let remoteQueueItem = queueItem as? RemoteQueueItem {
        // It's a RemoteQueueItem, and it's "loaded", so we better have a
        // RemoteQueue that is associated with the Session.
        let remoteQueue = AppDelegate.sharedDelegate.currentSession.queue as! RemoteQueue

        switch button {
        case .Left:
          remoteQueue.downvote(withQueueItem: remoteQueueItem)

        case .Right:
          remoteQueue.upvote(withQueueItem: remoteQueueItem)
        }
      }

      if let localQueueItem = queueItem as? LocalQueueItem {
        // We better have a LocalQueue if we have LocalQueueItem objects.
        let localQueue = AppDelegate.sharedDelegate.currentSession.queue as! LocalQueue

        switch button {
        case .Left:
          --localQueueItem.votes

        case .Right:
          ++localQueueItem.votes
        }

        localQueue.refresh()  // we updated the votes, so refresh the Queue
      }

      // Finally, refresh the cell since the content could be different.
      (cell as! QueueTableViewCell).updateContent(withQueueItem: queueItem)

    }
  }
}

extension UpNextTableViewController: NowPlayingViewDelegate {
  func nowPlayingViewTapped(nowPlayingView: NowPlayingView) {
    performSegueWithIdentifier("PushNowPlaying", sender: nil)
  }
}
