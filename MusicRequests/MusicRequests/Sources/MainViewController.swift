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
  private var topConstraint: NSLayoutConstraint?
  private var heightConstraint: NSLayoutConstraint?

  override func viewDidLoad() {
    super.viewDidLoad()

    // grab the reference that we need after initializing
    upNextViewController = childViewControllers.first as! UpNextTableViewController
    upNextViewController.mainViewController = self

    // get a reference to the view that needs to move, and make it visible
    viewToMove = upNextViewController.nowPlayingView
    view.addSubview(viewToMove)

    // create the constraints to size this view
    view.addConstraint(NSLayoutConstraint(
      item: viewToMove,
      attribute: .Leading,
      relatedBy: .Equal,
      toItem: view,
      attribute: .Leading,
      multiplier: 1,
      constant: 0
    ))

    view.addConstraint(NSLayoutConstraint(
      item: viewToMove,
      attribute: .Trailing,
      relatedBy: .Equal,
      toItem: view,
      attribute: .Trailing,
      multiplier: 1,
      constant: 0
    ))

    let topConstraint = NSLayoutConstraint(
      item: viewToMove,
      attribute: .Top,
      relatedBy: .Equal,
      toItem: view,
      attribute: .Top,
      multiplier: 1,
      constant: 0
    )
    view.addConstraint(topConstraint)
    self.topConstraint = topConstraint

    let heightConstraint = NSLayoutConstraint(
      item: viewToMove,
      attribute: .Height,
      relatedBy: .Equal,
      toItem: nil,
      attribute: .NotAnAttribute,
      multiplier: 0,
      constant: 0
    )
    viewToMove.addConstraint(heightConstraint)
    self.heightConstraint = heightConstraint
  }

  func updateViewPosition(inTableView tableView: UITableView) {
    var cellFrame = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
    cellFrame.size.height -= 1  // to make the separator visible

    var cellPosition = tableView.convertPoint(cellFrame.origin, toView: self.view)

    cellPosition.y = max(cellPosition.y, topLayoutGuide.length)  // can't go under nav bar

    let maximum = view.bounds.size.height - cellFrame.size.height
    cellPosition.y = min(cellPosition.y, maximum)  // can't go off the bottom of the screen

    heightConstraint?.constant = max(0, cellFrame.size.height)
    topConstraint?.constant = cellPosition.y
  }

}
