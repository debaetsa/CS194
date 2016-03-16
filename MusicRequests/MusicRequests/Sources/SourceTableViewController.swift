//
//  SourceTableViewController.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/14/16.
//
//

import UIKit

private enum Section: Int {
  case Local = 0
  case Remote
  case count
}

class SourceTableViewController: UITableViewController, UITextFieldDelegate {

  // capture the local session object to use throughout the view
  let localSession = AppDelegate.sharedDelegate.localSession

  var listener: NSObjectProtocol?
  let remoteSessionManager = AppDelegate.sharedDelegate.remoteSessionManager

  weak var broadcastSwitch: UISwitch!
  weak var nameTextField: UITextField!

  var localTableViewCells = [UITableViewCell]()

  override func viewDidLoad() {
    super.viewDidLoad()

    // create the static cell content
    createLocalCells()

    // set the initial state of all the views
    broadcastSwitch.on = localSession.broadcast
    nameTextField.text = localSession.name

    let center = NSNotificationCenter.defaultCenter()
    listener = center.addObserverForName(RemoteSessionManager.didUpdateNotification, object: remoteSessionManager, queue: nil) {
      [unowned self] (note) in

      self.tableView.reloadData()
    }
  }

  deinit {
    if let boundListener = listener {
      let center = NSNotificationCenter.defaultCenter()
      center.removeObserver(boundListener)
    }
  }

  private func createLocalCells() {
    var cell: UITableViewCell!

    cell = tableView.dequeueReusableCellWithIdentifier("RemoteCell")
    cell.textLabel?.text = "My \(UIDevice.currentDevice().model)"
    localTableViewCells.append(cell)

    cell = tableView.dequeueReusableCellWithIdentifier("BroadcastCell")
    broadcastSwitch = (cell.accessoryView as! UISwitch)
    localTableViewCells.append(cell)

    cell = tableView.dequeueReusableCellWithIdentifier("PlaylistCell")
    localTableViewCells.append(cell)

    cell = tableView.dequeueReusableCellWithIdentifier("NameCell")
    nameTextField = (cell.viewWithTag(1) as! UITextField)
    localTableViewCells.append(cell)
  }

  // MARK: - Actions

  @IBAction func didChangeBroadcastSwitch(sender: AnyObject?) {
    if nameTextField.isFirstResponder() {
      nameTextField.resignFirstResponder()
    }

    localSession.broadcast = broadcastSwitch.on
  }

  @IBAction func didChangeBroadcastName(sender: AnyObject?) {
    localSession.name = (nameTextField.text ?? "")
  }

  // MARK: - Text Field Delegate

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return Section.count.rawValue
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch Section(rawValue: section)! {
    case .Local:
      return localTableViewCells.count

    case .Remote:
      return max(remoteSessionManager.sessions.count, 1)

    default:
      return 0
    }
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch Section(rawValue: section)! {
    case .Local:
      return "Local"

    case .Remote:
      return "Remote"

    default:
      return nil
    }
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == Section.Local.rawValue {
      let cell = localTableViewCells[indexPath.row]

      if cell.reuseIdentifier == "RemoteCell" {
        cell.accessoryType = (AppDelegate.sharedDelegate.currentSession == AppDelegate.sharedDelegate.localSession)
          ? .Checkmark
          : .None
      }

      return cell

    } else {

      if remoteSessionManager.sessions.count == 0 {
        return tableView.dequeueReusableCellWithIdentifier("NoRemoteCell", forIndexPath: indexPath)

      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("RemoteCell", forIndexPath: indexPath)

        let session = remoteSessionManager.sessions[indexPath.row]
        cell.textLabel?.text = session.name

        let currentSession = AppDelegate.sharedDelegate.currentSession
        cell.accessoryType = (session === currentSession)
          ? UITableViewCellAccessoryType.Checkmark
          : UITableViewCellAccessoryType.None

        return cell
      }
    }
  }

  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    // This will be nil if the cell is not visible.  We should only allow
    // selection of visible cells.
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      return (cell.selectionStyle == UITableViewCellSelectionStyle.None) ? nil : indexPath
    }
    return nil
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let nextSession: Session

    switch indexPath.section {
    case Section.Local.rawValue where indexPath.row == 0:
      nextSession = AppDelegate.sharedDelegate.localSession
      break

    case Section.Remote.rawValue:
      nextSession = remoteSessionManager.sessions[indexPath.row]
      break

    default:
      return
    }

    // connect to the new Session (this will automatically connect)
    AppDelegate.sharedDelegate.currentSession = nextSession

    // We need to deselect the existing cell (if it is visible).
    for cell in tableView.visibleCells {
      if cell.accessoryType == .Checkmark {
        cell.accessoryType = .None
      }
    }

    // clear the row after it gets selected
    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    Style.darkTheme.sourceView(tableView, header: header)
  }

}
