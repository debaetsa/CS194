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
  let remoteSessions = AppDelegate.sharedDelegate.remoteSessionManager

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
  }

  private func createLocalCells() {
    var cell: UITableViewCell!

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
      return max(remoteSessions.sessions.count, 1)

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
      return localTableViewCells[indexPath.row]

    } else {

      if remoteSessions.sessions.count == 0 {
        return tableView.dequeueReusableCellWithIdentifier("NoRemoteCell", forIndexPath: indexPath)

      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("RemoteCell", forIndexPath: indexPath)

        let session = remoteSessions.sessions[indexPath.row]
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
    guard indexPath.section == Section.Remote.rawValue else {
      return
    }

    let session = remoteSessions.sessions[indexPath.row]
    session.connect()
    AppDelegate.sharedDelegate.currentSession = session

    // clear the row after it gets selected
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    Style.darkTheme.sourceView(tableView, header: header)
  }

  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the specified item to be editable.
  return true
  }
  */

  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the item to be re-orderable.
  return true
  }
  */

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

}
