//
//  QueueViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/29/16.
//
//

import UIKit

/** This is the overall container view controller.

   This contains the view controller that shows the Queue, and it also contains
   the button to choose songs from the library. */
class MainViewController: UIViewController {

  // we need a reference to this so that we can determine the cell location
  var upNextViewController: UpNextTableViewController!

  // we need a view that we can move around the screen to cover the cell
  private var viewToMove: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // grab the reference that we need after initializing
    upNextViewController = childViewControllers.first as! UpNextTableViewController
    upNextViewController.mainViewController = self

    // get a reference to the view that needs to move, and make it visible
    viewToMove = upNextViewController.nowPlayingView
    view.addSubview(viewToMove)
  }

  func updateViewPosition(inTableView tableView: UITableView) {
    var cellFrame = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
    cellFrame.size.height -= 1  // to make the separator visible

    var cellPosition = tableView.convertPoint(cellFrame.origin, toView: self.view)

    cellPosition.y = max(cellPosition.y, topLayoutGuide.length)  // can't go under nav bar

    let maximum = view.bounds.size.height - cellFrame.size.height
    cellPosition.y = min(cellPosition.y, maximum)  // can't go off the bottom of the screen

    viewToMove.frame = CGRect(origin: cellPosition, size: cellFrame.size)
  }

}
