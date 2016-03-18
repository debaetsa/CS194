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

  private enum RowLocal: Int {
    case Source = 0
    case Broadcast
    case Playlist
    case Name
    case count
  }
}

class SourceTableViewController: UITableViewController, UITextFieldDelegate {

  // capture the local session object to use throughout the view
  let localSession = AppDelegate.sharedDelegate.localSession

  var listener: NSObjectProtocol?
  let remoteSessionManager = AppDelegate.sharedDelegate.remoteSessionManager

  weak var broadcastSwitch: UISwitch!
  weak var nameTextField: UITextField!

  @IBOutlet weak var cellBroadcast: UITableViewCell!
  @IBOutlet weak var cellPlaylist: UITableViewCell!
  @IBOutlet weak var cellName: UITableViewCell!

  var localTableViewCells = [UITableViewCell]()

  override func viewDidLoad() {
    super.viewDidLoad()

    // get these objects after they are loaded from the storyboard file
    broadcastSwitch = cellBroadcast.accessoryView as! UISwitch
    nameTextField = cellName.viewWithTag(1) as! UITextField

    // set the initial state of all the views
    broadcastSwitch.on = localSession.broadcast
    nameTextField.text = localSession.name

    let center = NSNotificationCenter.defaultCenter()
    listener = center.addObserverForName(RemoteSessionManager.didUpdateNotification, object: remoteSessionManager, queue: nil) {
      [unowned self] (note) in

      self.tableView.reloadData()
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    updatePlaylistName()

    if let selectedIndexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
    }
  }

  deinit {
    if let boundListener = listener {
      let center = NSNotificationCenter.defaultCenter()
      center.removeObserver(boundListener)
    }
  }

  private func updatePlaylistName() {
    let maybePlaylist = (localSession.sourceLibrary as? FilteredLibrary)?.playlist
    if let playlist = maybePlaylist {
      cellPlaylist.detailTextLabel?.text = playlist.name
    } else {
      cellPlaylist.detailTextLabel?.text = "All Music"
    }
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
      if AppDelegate.sharedDelegate.currentSession is LocalSession {
        return Section.RowLocal.count.rawValue
      } else {
        return 1  // only show one row if a remote session is selected
      }

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
      switch indexPath.row {
      case Section.RowLocal.Name.rawValue:
        return cellName

      case Section.RowLocal.Broadcast.rawValue:
        return cellBroadcast

      case Section.RowLocal.Playlist.rawValue:
        return cellPlaylist

      default:
        let cell = tableView.dequeueReusableCellWithIdentifier("RemoteCell", forIndexPath: indexPath)
        cell.textLabel?.text = "My \(UIDevice.currentDevice().model)"

        let session = AppDelegate.sharedDelegate.localSession
        let currentSession = AppDelegate.sharedDelegate.currentSession
        cell.accessoryType = (currentSession === session) ? .Checkmark : .None

        return cell
      }

    } else {

      if remoteSessionManager.sessions.count == 0 {
        return tableView.dequeueReusableCellWithIdentifier("NoRemoteCell", forIndexPath: indexPath)

      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("RemoteCell", forIndexPath: indexPath)

        let session = remoteSessionManager.sessions[indexPath.row]
        cell.textLabel?.text = session.name

        let currentSession = AppDelegate.sharedDelegate.currentSession
        cell.accessoryType = (session === currentSession) ? .Checkmark : .None

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

    if !(nextSession is LocalSession) {
      // We're not using the LocalSession, so turn it off.
      broadcastSwitch.on = false
      localSession.broadcast = false
    }

    // We need to deselect the existing cell (if it is visible).
    for cell in tableView.visibleCells {
      if cell.accessoryType == .Checkmark {
        cell.accessoryType = .None
      }
    }

    // update the checkmark (always)
    tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark

    // we need to reload this section whenever we make a different selection
    tableView.reloadSections(NSIndexSet(index: Section.Local.rawValue), withRowAnimation: .Automatic)

    // clear the row after it gets selected
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    Style.darkTheme.sourceView(tableView, header: header, textField: nameTextField)
  }

}
