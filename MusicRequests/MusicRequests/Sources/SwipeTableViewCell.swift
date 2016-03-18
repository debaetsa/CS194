//
//  SwipeCell.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/29/16.
//
//

import UIKit

/** Implement the delegate for each cell to know when a button is selected.

   This should probably be set when building the cell so that everything is
   connected properly. */
protocol SwipeTableViewCellDelegate: class {
  // The "class" specifier above means that this protocl can only be applied to
  // classes.  This is necessary to allow us to use a weak reference.

  /** Called when a button is "pressed".

   Though note that a button is "pressed" when it is fully-swiped. */
  func swipeTableViewCell(cell: SwipeTableViewCell, didPressButton: SwipeTableViewCell.Location)
}

class SwipeTableViewCell: UITableViewCell {

  /** The location of the buttons.

   Use the notify the delegate of which button was pressed. */
  enum Location {
    case Left
    case Right
  }

  /** Stores the view that we slide to show/hide the buttons. */
  @IBOutlet weak var customContentView: UIView!
  @IBOutlet weak var leftOffsetContraint: NSLayoutConstraint!
  @IBOutlet weak var rightOffsetConstraint: NSLayoutConstraint!

  /** References to the views with the buttons.
   
    These are needed to allow us to limit the scrolling to the width of the
    button. */
  @IBOutlet weak var customLeftView: UIView!
  @IBOutlet weak var customRightView: UIView!

  /** The delegate where notifications are sent about button selections.
   
   If there is not a delegate, then the cell will not be swipeable.  It would 
   be pointless since there is nothing to handle the action when it occurs.
   
   This also give the ability to disable swiping as needed. */
  weak var delegate: SwipeTableViewCellDelegate? {
    didSet {
      updateGestureRecognizer()
    }
  }

  /** Stores the gesture recognizer for this cell. */
  private var panGestureRecognizer: UIPanGestureRecognizer!

  /** Stores the offset of the view as it is moved. */
  private var offset: CGFloat = 0 {
    didSet {
      leftOffsetContraint.constant = offset
      rightOffsetConstraint.constant = -offset
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    // create the gesture recognizer
    let recognizer = UIPanGestureRecognizer()
    recognizer.addTarget(self, action: "handlePanRecognizer:")
    recognizer.delegate = self
    panGestureRecognizer = recognizer

    // set the background color
    customContentView.backgroundColor = Style.dark  // use the "dark" color
    customLeftView.backgroundColor = UIColor.redColor()
    customRightView.backgroundColor = UIColor.greenColor()
  }

  private var addedGestureRecognizer = false
  private func updateGestureRecognizer() {
    let needGestureRecognizer = (delegate != nil)

    if needGestureRecognizer == addedGestureRecognizer {
      return  // they already match
    }

    if needGestureRecognizer {
      customContentView.addGestureRecognizer(panGestureRecognizer)
    } else {
      customContentView.removeGestureRecognizer(panGestureRecognizer)
    }
    addedGestureRecognizer = needGestureRecognizer
  }

  private func setOffset(offset: CGFloat, animated: Bool) {
    // clamp the offset based on the sizes of the views
    var boundOffset = offset
    boundOffset = min(boundOffset, customLeftView.bounds.size.width)
    boundOffset = max(boundOffset, -customRightView.bounds.size.width)
    self.offset = boundOffset

    if animated {
      contentView.setNeedsUpdateConstraints()  // update other constraints

      UIView.animateWithDuration(0.2,
        delay: 0,
        options: .CurveEaseOut,
        animations: {
          self.contentView.layoutIfNeeded()  // actually update all the frames
        },
        completion: nil)
    }
  }

  private var canSendPress = false

  func handlePanRecognizer(recognizer: UIPanGestureRecognizer) {
    // I think this needs to be non-private to allow its use as a selector.

    switch recognizer.state {
    case .Cancelled: fallthrough
    case .Ended:
      if canSendPress {
        checkForButtonPress()
        canSendPress = false  // can't send another press until we get "Began"
      }
      setOffset(0, animated: true)

    case .Began:
      canSendPress = true  // since we started, we can send a button pressed
      fallthrough

    case .Changed:
      setOffset(recognizer.translationInView(self.contentView).x, animated: false)

    default:
      break
    }
  }

  /** Sends a button press if a button is pressed. */
  private func checkForButtonPress() {
    var maybeButton: Location? = nil  // no button

    if offset >= customLeftView.bounds.size.width {
      // All the way to the left, so it's a left button press.
      maybeButton = .Left

    } else if offset <= -customRightView.bounds.size.width {
      maybeButton = .Right
    }

    if let button = maybeButton {
      delegate?.swipeTableViewCell(self, didPressButton: button)
    }
  }

  override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if gestureRecognizer === panGestureRecognizer {
      // use the velocity to determine the scroll direction
      // simply checking the ∆ of the scroll does not have enough precision
      let velocity = panGestureRecognizer.velocityInView(self.contentView)

      // if we are scrolling more horizontally, capture this as a side swipe
      return (abs(velocity.x) > abs(velocity.y))

    } else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
  }

  override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {

    if gestureRecognizer === panGestureRecognizer {
      if otherGestureRecognizer is UIPanGestureRecognizer {
        return false
      }
      return true
    }
    return false  // super doesn't respond to this?
  }

}
